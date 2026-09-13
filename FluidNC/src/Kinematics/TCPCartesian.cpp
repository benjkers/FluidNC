// Copyright (c) 2026 - benjkers
// Use of this source code is governed by a GPLv3 license that can be found in the LICENSE file.

/*
    TCPCartesian.cpp

    ------------------------------------------------------------------------
    THE TRANSFORM
    ------------------------------------------------------------------------
    target[] arriving at cartesian_to_motors() has already had G54, G92 and
    the G43.1 tool length offset applied by the gcode core (see get_wco() in
    System.cpp). So target[] is the GAUGE LINE position, not the tool tip.

    The spindle does not tilt on this machine, so the tool vector is fixed in
    the machine frame. Only the TIP is carried around by the rotary. Hence:

        strip the tool length offset  ->  rotate the tip  ->  add it back

        phi   = b_sign * B_degrees
        d     = (target - TLO) - C
        mach  = C + Rodrigues(d, axis, phi) + TLO

    where C is any point on the rotary axis and 'axis' is the measured unit
    vector along it. With axis = (0,1,0) this collapses to the familiar

        Xm = Cx + dx*cos(phi) + dz*sin(phi)
        Zm = Cz - dx*sin(phi) + dz*cos(phi)
        Ym = unchanged

    but a real rotary is never exactly parallel to Y, and the general form
    costs nothing extra to evaluate.

    If you forget to strip the tool length L, the error is
        dX = -L*sin(B)      dZ = -L*(1 - cos(B))
    which for a 90 mm tool at B90 is 90 mm in BOTH axes, same direction.

    ------------------------------------------------------------------------
    SEGMENTATION
    ------------------------------------------------------------------------
    With B held constant the transform is a rigid rotation - an affine map -
    so straight lines stay straight and lengths are preserved exactly.
    Ordinary 3-axis cutting at a fixed index angle therefore needs NO
    segmentation and NO feed scaling and costs one extra matrix multiply per
    block. Only moves that actually change B get split up.

    ------------------------------------------------------------------------
    SOFT LIMITS
    ------------------------------------------------------------------------
    The core checks soft limits in mc_linear() -> invalid_line() against what
    it believes is machine space. Under TCP that is the PART frame, so the
    stock check is meaningless. invalid_line() is overridden to transform
    first, invalid_arc() defers to the per-segment motor-space check, and
    cartesian_to_motors() re-checks every segment because the swept arc can
    leave the envelope even when both endpoints are inside it.
*/

#include "TCPCartesian.h"

#include "Machine/MachineConfig.h"  // config, copyAxes
#include "Machine/Axes.h"           // Axes::_numberAxis, axisName
#include "Limit.h"                  // limitsMin/MaxPosition, limit_error
#include "GCode.h"                  // gc_state.tool_length_offset[]
#include "MotionControl.h"          // mc_move_motors

#include <math.h>
#include <algorithm>

namespace Kinematics {

    static const float KDEG2RAD = 3.14159265358979f / 180.0f;

    // The one configured instance, if this machine uses this kinematics.
    // Set in init(), used by the M128 / M129 free functions below.
    static TCPCartesian* s_instance = nullptr;

    // =======================================================================
    // Configuration
    // =======================================================================
    void TCPCartesian::group(Configuration::HandlerBase& handler) {
        handler.item("pivot_x_mm", _pivot_x);
        handler.item("pivot_y_mm", _pivot_y);
        handler.item("pivot_z_mm", _pivot_z);

        handler.item("axis_x", _axis_x);
        handler.item("axis_y", _axis_y);
        handler.item("axis_z", _axis_z);

        handler.item("segment_length_mm", _seg_len_mm);
        handler.item("segment_angle_deg", _seg_ang_deg);
        handler.item("max_segments", _max_segments);

        handler.item("scale_feedrate", _scale_feed);
        handler.item("max_feed_scale", _max_feed_scale);

        handler.item("rotate_tool_offset", _rotate_tlo);
        handler.item("check_soft_limits", _check_soft_limits);
    }

    void TCPCartesian::afterParse() {
        _seg_ang_deg    = std::max(_seg_ang_deg, 0.02f);
        _seg_len_mm     = std::max(_seg_len_mm, 0.05f);
        _max_feed_scale = std::max(_max_feed_scale, 1.0f);

        float m = sqrtf(_axis_x * _axis_x + _axis_y * _axis_y + _axis_z * _axis_z);
        if (m < 1e-6f) {
            _axis_x = 0.0f;
            _axis_y = 1.0f;
            _axis_z = 0.0f;
        } else {
            _axis_x /= m;
            _axis_y /= m;
            _axis_z /= m;
        }

        _tcp_active = false;  // always off at boot
        _suspended  = false;
    }

    // Find the rotary axis by looking at what is actually driven.
    //
    // Testing for the existence of an Axis or a Motor object does NOT work.
    // Declaring x,y,z,b with no 'a' still produces a complete set of objects:
    // Axes::afterParse() creates an Axis for every gap in the letter
    // sequence, and Axis::afterParse() then hands each one a Motor. Both
    // exist so the rest of the firmware can index the arrays without
    // checking. The phantom A axis on this machine is exactly that.
    //
    // What the placeholders do NOT have is a real driver -- theirs is
    // null_motor, and Motor::isReal() reports it. Axis.cpp uses the same
    // test to decide whether an axis is dual-motor.
    //
    // So this works for whatever letter you used. Declare 'b' and the rotary
    // is index 4; declare 'a' and it is index 3. Nothing to keep in sync by
    // hand, and the phantoms are ignored.
    bool TCPCartesian::findRotaryAxis() {
        auto   axes   = config->_axes;
        axis_t n_axis = Axes::_numberAxis;
        axis_t found  = INVALID_AXIS;
        int    count  = 0;

        for (axis_t axis = A_AXIS; axis < n_axis; axis++) {
            auto a = axes->_axis[axis];
            if (!a) {
                continue;
            }
            auto m = a->_motors[0];
            if (m && m->isReal()) {
                if (count == 0) {
                    found = axis;
                }
                count++;
            }
        }

        if (count == 0) {
            log_error(name() << ": no rotary axis is configured. Declare a, b or c "
                             << "in the axes section, or use Cartesian kinematics.");
            return false;
        }
        if (count > 1) {
            log_error(name() << ": " << count << " rotary axes are configured. This "
                             << "kinematics compensates ONE. Using "
                             << Machine::Axes::axisName(found) << ".");
        }
        _rot_index = found;
        return true;
    }

    void TCPCartesian::init() {
        s_instance = this;

        log_info("Kinematic system: " << name());

        if (!findRotaryAxis()) {
            // Leave _rot_index INVALID. tcp_set() refuses below, so M128
            // raises a gcode error instead of indexing past the array.
            init_position();
            return;
        }

        log_info("  rotary axis " << Machine::Axes::axisName(_rot_index) << " (index "
                                  << int(_rot_index) << "), sign " << ROT_SIGN);
        log_info("  pivot  X " << _pivot_x << "  Y " << _pivot_y << "  Z " << _pivot_z);
        log_info("  axis   " << _axis_x << ", " << _axis_y << ", " << _axis_z);
        log_info("  mode " << (_rotate_tlo ? "RTCP tilting head" : "RPCP rotary table")
                           << ", TCP off at boot (M128 enables)");

        // Cartesian::init_position() fills _min_motor_pos / _max_motor_pos via
        // transform_cartesian_to_motors(). TCP is off here, so that is an
        // identity and the stored envelope is the true machine envelope.
        init_position();
    }

    // =======================================================================
    // Pure transform
    // =======================================================================
    void TCPCartesian::toolOffset(float* tlo) const {
        if (_rotate_tlo) {
            // Tilting head: the tool vector rotates with the head, so it stays
            // inside the rotation.
            tlo[X_AXIS] = tlo[Y_AXIS] = tlo[Z_AXIS] = 0.0f;
            return;
        }
        tlo[X_AXIS] = gc_state.tool_length_offset[X_AXIS];
        tlo[Y_AXIS] = gc_state.tool_length_offset[Y_AXIS];
        tlo[Z_AXIS] = gc_state.tool_length_offset[Z_AXIS];
    }

    // Rodrigues rotation of v about the (unit) configured axis by phi radians.
    // The rotary work offset defines where the part's zero ORIENTATION is,
    // the same way the XYZ offsets define where its origin is. So everything
    // below rotates by the WORK angle: set G54 B zero with the part's face
    // up and a programmed Z move is a machine Z move, whatever the rotary
    // reads on the machine DRO.
    //
    // Without this, the reference orientation is wherever the rotary happens
    // to home, and you are back to having to mount the part to suit the
    // machine -- exactly the constraint TCP exists to remove for XYZ.
    //
    // With no rotary offset set this returns zero and nothing changes.
    float TCPCartesian::rotaryOffset() const {
        return gc_state.coord_system[_rot_index] + gc_state.coord_offset[_rot_index];
    }

    // A work offset is a FRAME: its rotary component fixes the part's zero
    // ORIENTATION, its XYZ component fixes the origin's machine position AT
    // that orientation. They are not independent.
    //
    // So when the rotary component changes, the XYZ component has to rotate
    // about the pivot by the same amount, or it keeps describing where the
    // origin sat at the OLD orientation and the next move drives to the old
    // position. Rotating it keeps the physical origin exactly where it is:
    //
    //     O_new = C + R(sign * delta) * (O_old - C)
    //
    // Nothing moves - an offset is never a motion command - and afterwards
    // the order you set things in stops mattering. Level the part, then
    // probe XYZ, or fix up the level afterwards; both give the same frame.
    //
    // Only the XYZ triple rotates. The rotary component is the new value
    // being set, and any other axes are untouched.
    void TCPCartesian::reorientOffset(const float* oldOffsets, float* newOffsets) {
        if (_rot_index == INVALID_AXIS) {
            return;
        }
        const float delta = newOffsets[_rot_index] - oldOffsets[_rot_index];
        if (fabsf(delta) < 1e-6f) {
            return;  // pure translation, nothing to reorient
        }

        const float phi = ROT_SIGN * delta * KDEG2RAD;

        float d[3] = { oldOffsets[X_AXIS] - _pivot_x, oldOffsets[Y_AXIS] - _pivot_y, oldOffsets[Z_AXIS] - _pivot_z };
        float r[3];
        rotateAboutAxis(d, phi, r);

        newOffsets[X_AXIS] = _pivot_x + r[0];
        newOffsets[Y_AXIS] = _pivot_y + r[1];
        newOffsets[Z_AXIS] = _pivot_z + r[2];

        log_info(name() << ": reference orientation moved " << delta << " deg, origin rotated with it to X"
                        << newOffsets[X_AXIS] << " Y" << newOffsets[Y_AXIS] << " Z" << newOffsets[Z_AXIS]);
    }

    void TCPCartesian::rotateAboutAxis(const float* v, float phi, float* out) const {
        const float c = cosf(phi);
        const float s = sinf(phi);
        const float k = 1.0f - c;

        const float nx = _axis_x, ny = _axis_y, nz = _axis_z;
        const float dot = nx * v[0] + ny * v[1] + nz * v[2];

        // n x v
        const float cx = ny * v[2] - nz * v[1];
        const float cy = nz * v[0] - nx * v[2];
        const float cz = nx * v[1] - ny * v[0];

        out[0] = v[0] * c + cx * s + nx * dot * k;
        out[1] = v[1] * c + cy * s + ny * dot * k;
        out[2] = v[2] * c + cz * s + nz * dot * k;
    }

    void TCPCartesian::forward(const float* part, float bDeg, const float* tlo, float* mach) const {
        const float phi = ROT_SIGN * bDeg * KDEG2RAD;

        float d[3] = { (part[X_AXIS] - tlo[X_AXIS]) - _pivot_x,
                       (part[Y_AXIS] - tlo[Y_AXIS]) - _pivot_y,
                       (part[Z_AXIS] - tlo[Z_AXIS]) - _pivot_z };
        float r[3];
        rotateAboutAxis(d, phi, r);

        mach[X_AXIS] = _pivot_x + r[0] + tlo[X_AXIS];
        mach[Y_AXIS] = _pivot_y + r[1] + tlo[Y_AXIS];
        mach[Z_AXIS] = _pivot_z + r[2] + tlo[Z_AXIS];
    }

    void TCPCartesian::inverse(const float* mach, float bDeg, const float* tlo, float* part) const {
        const float phi = ROT_SIGN * bDeg * KDEG2RAD;

        float d[3] = { (mach[X_AXIS] - tlo[X_AXIS]) - _pivot_x,
                       (mach[Y_AXIS] - tlo[Y_AXIS]) - _pivot_y,
                       (mach[Z_AXIS] - tlo[Z_AXIS]) - _pivot_z };
        float r[3];
        rotateAboutAxis(d, -phi, r);

        part[X_AXIS] = _pivot_x + r[0] + tlo[X_AXIS];
        part[Y_AXIS] = _pivot_y + r[1] + tlo[Y_AXIS];
        part[Z_AXIS] = _pivot_z + r[2] + tlo[Z_AXIS];
    }

    // =======================================================================
    // Limits
    // =======================================================================
    bool TCPCartesian::outOfTravel(const float* motors, axis_t n_axis, bool raise) const {
        if (!_check_soft_limits) {
            return false;
        }
        auto axes = config->_axes;
        for (axis_t axis = X_AXIS; axis < n_axis; axis++) {
            if (axis == _rot_index) {
                continue;  // rotary passes straight through
            }
            // A gap in the axis list is normal: declaring x,y,z,b with no 'a'
            // leaves _axis[3] null while _numberAxis is 5. Dereferencing that
            // is a crash, not a config error.
            if (!axes->_axis[axis] || !axes->_axis[axis]->_softLimits) {
                continue;
            }
            const float c = motors[axis];
            if (c < limitsMinPosition(axis) || c > limitsMaxPosition(axis)) {
                if (raise) {
                    limit_error(axis, c);
                }
                return true;
            }
        }
        return false;
    }

    bool TCPCartesian::invalid_line(float* cartesian) {
        if (!transformEnabled()) {
            return Cartesian::invalid_line(cartesian);
        }
        // Check the ENDPOINT in motor space. The swept path is checked again
        // per segment inside cartesian_to_motors(), because a move that
        // changes B can bulge outside the envelope between its endpoints.
        float motors[MAX_N_AXIS];
        transform_cartesian_to_motors(motors, cartesian);
        return outOfTravel(motors, Axes::_numberAxis, true);
    }

    bool TCPCartesian::invalid_arc(float*            target,
                                         plan_line_data_t* pl_data,
                                         float*            position,
                                         float             center[3],
                                         float             radius,
                                         axis_t            caxes[3],
                                         bool              is_clockwise_arc,
                                         uint32_t          rotations) {
        if (!transformEnabled()) {
            return Cartesian::invalid_arc(target, pl_data, position, center, radius, caxes, is_clockwise_arc, rotations);
        }
        // Under TCP a circle in the part frame is still a circle in motor
        // space (B does not change during an arc) but it sits in a rotated
        // plane, so the axis-crossing shortcut in Cartesian::invalid_arc does
        // not apply. Defer to the per-segment motor-space check: mc_arc feeds
        // its segments through mc_linear_no_check -> cartesian_to_motors,
        // which checks each one.
        pl_data->limits_checked = true;
        return false;
    }

    // =======================================================================
    // Motion
    // =======================================================================
    bool TCPCartesian::cartesian_to_motors(float* target, plan_line_data_t* pl_data, float* position) {
        const axis_t n_axis = Axes::_numberAxis;

        // Bypass for: TCP off (M129), a G53 block, and any system motion -
        // homing and parking plan in motor space and must not be transformed.
        if (!transformEnabled() || pl_data->motion.systemMotion) {
            return mc_move_motors(target, pl_data);
        }

        float tlo[3];
        toolOffset(tlo);

        // Machine angles in, work angles to the transform.
        const float roff = rotaryOffset();
        const float b0   = position[_rot_index];
        const float b1   = target[_rot_index];
        const float db   = b1 - b0;

        float motors[MAX_N_AXIS];

        // ---- Fast path: B is not moving -----------------------------------
        // Constant B makes the transform affine, so the line stays a line and
        // its length is unchanged. One block, original feed, no approximation.
        if (fabsf(db) < 1e-6f) {
            forward(target, b1 - roff, tlo, motors);
            for (axis_t a = A_AXIS; a < n_axis; a++) {
                motors[a] = target[a];
            }
            if (outOfTravel(motors, n_axis, true)) {
                return false;
            }
            return mc_move_motors(motors, pl_data);
        }

        // ---- Segmented path ------------------------------------------------
        const float dx = target[X_AXIS] - position[X_AXIS];
        const float dy = target[Y_AXIS] - position[Y_AXIS];
        const float dz = target[Z_AXIS] - position[Z_AXIS];
        const float cart_len = sqrtf(dx * dx + dy * dy + dz * dz);

        int segs = int(ceilf(fabsf(db) / _seg_ang_deg));
        if (cart_len > _seg_len_mm) {
            segs = std::max(segs, int(ceilf(cart_len / _seg_len_mm)));
        }
        segs = std::max(segs, 1);
        if (segs > _max_segments) {
            log_warn("TCPCartesian: clamping " << segs << " segments to " << _max_segments);
            segs = _max_segments;
        }

        const float base_feed = pl_data->feed_rate;
        const bool  do_scale  = _scale_feed && !pl_data->motion.rapidMotion;

        float prev_m[MAX_N_AXIS];
        forward(position, b0 - roff, tlo, prev_m);

        float seg[MAX_N_AXIS];

        for (int i = 1; i <= segs; i++) {
            const float t = float(i) / float(segs);

            // Interpolate in the PART frame - that is the whole point. It is
            // the tip path relative to the part that has to stay straight.
            seg[X_AXIS] = position[X_AXIS] + dx * t;
            seg[Y_AXIS] = position[Y_AXIS] + dy * t;
            seg[Z_AXIS] = position[Z_AXIS] + dz * t;

            const float b = b0 + db * t;

            forward(seg, b - roff, tlo, motors);
            motors[_rot_index] = b;  // the MOTOR target stays a machine angle
            for (axis_t a = A_AXIS; a < n_axis; a++) {
                if (a != _rot_index) {
                    motors[a] = position[a] + (target[a] - position[a]) * t;
                }
            }

            if (outOfTravel(motors, n_axis, true)) {
                pl_data->feed_rate = base_feed;
                return false;
            }

            if (do_scale) {
                if (pl_data->motion.inverseTime) {
                    // G93: the whole BLOCK must take 1/F minutes, so each of N
                    // equal-fraction segments takes 1/(F*N). Without this the
                    // block runs N times too slow.
                    pl_data->feed_rate = base_feed * float(segs);
                } else if (cart_len > 1e-6f) {
                    // G94: hold the feed at the TIP. The segment must take
                    // (cart_len/segs)/F minutes, so the motors run at
                    // F * motor_len / cart_len.
                    const float mdx = motors[X_AXIS] - prev_m[X_AXIS];
                    const float mdy = motors[Y_AXIS] - prev_m[Y_AXIS];
                    const float mdz = motors[Z_AXIS] - prev_m[Z_AXIS];
                    const float mlen = sqrtf(mdx * mdx + mdy * mdy + mdz * mdz);
                    const float clen = cart_len / float(segs);

                    float ratio = mlen / clen;
                    ratio       = std::min(ratio, _max_feed_scale);
                    ratio       = std::max(ratio, 1.0f / _max_feed_scale);
                    pl_data->feed_rate = base_feed * ratio;
                }
                // Pure rotary index (cart_len == 0) under G94: the tip does
                // not move relative to the part, so a tip feed rate is
                // undefined. Leave F alone - the machine sweeps the
                // compensation arc at F mm/min, which is predictable. The
                // planner's per-axis rate and accel limits are the backstop.
            }

            if (!mc_move_motors(motors, pl_data)) {
                pl_data->feed_rate = base_feed;
                return false;
            }

            prev_m[X_AXIS] = motors[X_AXIS];
            prev_m[Y_AXIS] = motors[Y_AXIS];
            prev_m[Z_AXIS] = motors[Z_AXIS];
        }

        pl_data->feed_rate = base_feed;
        return true;
    }

    void TCPCartesian::motors_to_cartesian(float* cartesian, float* motors, axis_t n_axis) {
        if (!transformEnabled()) {
            copyAxes(cartesian, motors);
            return;
        }

        float tlo[3];
        toolOffset(tlo);

        // Temp, so this is safe if the caller aliases the two buffers.
        float out[3];
        inverse(motors, motors[_rot_index] - rotaryOffset(), tlo, out);

        copyAxes(cartesian, motors);
        cartesian[X_AXIS] = out[X_AXIS];
        cartesian[Y_AXIS] = out[Y_AXIS];
        cartesian[Z_AXIS] = out[Z_AXIS];
    }

    bool TCPCartesian::transform_cartesian_to_motors(float* motors, float* cartesian) {
        if (!transformEnabled()) {
            copyAxes(motors, cartesian);
            return true;
        }

        float tlo[3];
        toolOffset(tlo);

        float out[3];
        forward(cartesian, cartesian[_rot_index] - rotaryOffset(), tlo, out);

        copyAxes(motors, cartesian);
        motors[X_AXIS] = out[X_AXIS];
        motors[Y_AXIS] = out[Y_AXIS];
        motors[Z_AXIS] = out[Z_AXIS];
        return true;
    }

    // =======================================================================
    // Homing and jogging
    // =======================================================================
    bool TCPCartesian::canHome(AxisMask axisMask) {
        if (transformEnabled()) {
            // Cartesian::homing_move() builds its target by adding distances
            // to get_mpos(), which under TCP is a PART frame position. Rather
            // than silently changing a modal state the operator set, refuse.
            log_error("TCP is active. Send M129 before homing.");
            return false;
        }
        return Cartesian::canHome(axisMask);
    }

    void TCPCartesian::constrain_jog(float* target, plan_line_data_t* pl_data, float* position) {
        if (!transformEnabled()) {
            Cartesian::constrain_jog(target, pl_data, position);
            return;
        }

        // Under TCP a straight jog in the part frame traces a curve in motor
        // space when B moves, so clamping each axis of the target separately
        // is wrong. Bisect the jog fraction instead, until the endpoint sits
        // inside motor travel.
        const axis_t n_axis = Axes::_numberAxis;
        float motors[MAX_N_AXIS];

        transform_cartesian_to_motors(motors, target);
        if (!outOfTravel(motors, n_axis, false)) {
            pl_data->limits_checked = true;
            return;
        }

        float lo = 0.0f, hi = 1.0f;
        float probe[MAX_N_AXIS];
        for (int iter = 0; iter < 16; iter++) {
            const float mid = 0.5f * (lo + hi);
            for (axis_t a = X_AXIS; a < n_axis; a++) {
                probe[a] = position[a] + (target[a] - position[a]) * mid;
            }
            transform_cartesian_to_motors(motors, probe);
            if (outOfTravel(motors, n_axis, false)) {
                hi = mid;
            } else {
                lo = mid;
            }
        }
        for (axis_t a = X_AXIS; a < n_axis; a++) {
            target[a] = position[a] + (target[a] - position[a]) * lo;
        }
        log_debug("Jog constrained by TCP motor travel");
        pl_data->limits_checked = true;
    }

    // =======================================================================
    // M128 / M129 control surface
    // =======================================================================
    bool tcp_supported() {
        return s_instance != nullptr && s_instance->rotaryAxis() != INVALID_AXIS;
    }

    bool tcp_set(bool on) {
        if (!s_instance || s_instance->rotaryAxis() == INVALID_AXIS) {
            return false;
        }
        s_instance->setTcp(on);
        s_instance->setSuspended(false);
        return true;
    }

    bool tcp_is_active() {
        return s_instance && s_instance->tcpActive();
    }

    void tcp_suspend(bool suspended) {
        if (s_instance) {
            s_instance->setSuspended(suspended);
        }
    }

    void tcp_reorient_offset(const float* oldOffsets, float* newOffsets) {
        if (s_instance && s_instance->tcpActive()) {
            s_instance->reorientOffset(oldOffsets, newOffsets);
        }
    }

    // Configuration registration
    namespace {
        KinematicsFactory::InstanceBuilder<TCPCartesian> registration("TCPCartesian");
    }

}