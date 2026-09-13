// Copyright (c) 2026 - benjkers
// Use of this source code is governed by a GPLv3 license that can be found in the LICENSE file.

#pragma once

/*
    TCPCartesian.h

    Rotational Part Centre Point (RPCP) compensation for one rotary axis that
    is mounted on the table and carries the part.

    THIS MACHINE
        Y is the table. The rotary (B) is mounted on the table with its axis
        nominally parallel to Y, and carries the part. The spindle rides on Z,
        Z rides on X. The spindle does NOT tilt, so the tool vector is always
        machine -Z no matter what B does.

    WHAT IT GIVES YOU
        With TCP active (M128) the program is written in the PART frame with
        the work offset anywhere convenient on the part - it no longer has to
        sit on the centre of rotation. The pivot location and the MEASURED
        axis direction are applied here, so a rotary that is not perfectly
        parallel to Y is compensated rather than tolerated.

    WHY IT SUBCLASSES Cartesian
        Cartesian already owns homing (axesVector / homing_move), dual-motor
        limit handling, switch rearming and the fast arc limit check. None of
        that changes here. CoreXY in this same tree subclasses Cartesian for
        the same reason. Nothing in Cartesian.cpp or Cartesian.h is modified.

    TCP IS OFF AT BOOT and is switched by M128 / M129 through the free
    functions at the bottom of this header, so Kinematics.h needs no changes
    either.

    THE TRANSFORM ROTATES BY THE *WORK* ANGLE, NOT THE RAW MACHINE ANGLE.

    It has to. This rotary has no homing, so machine B zero is wherever the
    table happened to be sitting at power-on -- an arbitrary number that
    cannot be a geometry reference. The reference has to come from the work
    offset, and because it lives in the WCS it is per-part: several parts can
    sit on the table at different clockings, each levelled into its own
    G54..G59 with its own B offset and its own XYZ, and TCP works across all
    of them.

    So a work offset here is a FRAME, not just a translation: the rotary
    component says where the part's zero ORIENTATION is, the XYZ component
    says where its origin is AT THAT ORIENTATION. The two are not
    independent, which is why reorientOffset() rotates one when the other
    changes.

    CONSEQUENCE OF NO B HOMING: every stored B offset is only valid for the
    power cycle it was measured in. After a reset, or any loss of B position,
    the clocking that offset refers to no longer corresponds to the same
    machine angle -- and because the XYZ component is expressed at that
    orientation, it goes stale with it. Re-level before cutting.

    THE ROTARY AXIS IS DISCOVERED, NOT CONFIGURED. init() scans the axis tree
    for the one axis beyond XYZ that actually has a motor, so declaring 'b'
    gives index 4 and declaring 'a' gives index 3 with nothing to keep in
    sync by hand. Axes::afterParse() creates placeholder objects for gaps in
    the letter sequence, which is why the test is "has a motor" rather than
    "is not null".
*/

#include "Cartesian.h"

namespace Kinematics {

    class TCPCartesian : public Cartesian {
    public:
        TCPCartesian(const char* name) : Cartesian(name) {}

        TCPCartesian(const TCPCartesian&)            = delete;
        TCPCartesian(TCPCartesian&&)                 = delete;
        TCPCartesian& operator=(const TCPCartesian&) = delete;
        TCPCartesian& operator=(TCPCartesian&&)      = delete;

        // ---- Kinematic interface ------------------------------------------
        void init() override;

        bool cartesian_to_motors(float* target, plan_line_data_t* pl_data, float* position) override;
        void motors_to_cartesian(float* cartesian, float* motors, axis_t n_axis) override;

        // NOTE on argument order: the base class declares
        //     transform_cartesian_to_motors(float* motors, float* cartesian)
        // i.e. the FIRST argument is the OUTPUT (motor space) and the second
        // is the input. Cartesian.h has the parameter names the other way
        // round, but Cartesian.cpp and Kinematics.cpp both use out-first.
        // Follow the .cpp, not the .h.
        bool transform_cartesian_to_motors(float* motors, float* cartesian) override;

        bool invalid_line(float* cartesian) override;
        bool invalid_arc(float*            target,
                         plan_line_data_t* pl_data,
                         float*            position,
                         float             center[3],
                         float             radius,
                         axis_t            caxes[3],
                         bool              is_clockwise_arc,
                         uint32_t          rotations) override;

        void constrain_jog(float* target, plan_line_data_t* pl_data, float* position) override;
        bool canHome(AxisMask axisMask) override;

        // ---- Configuration --------------------------------------------------
        void group(Configuration::HandlerBase& handler) override;
        void afterParse() override;

        // ---- Pure transform, also used by the host-side unit test -----------
        // part[] and mach[] are XYZ only. bDeg is the rotary angle in degrees.
        // tlo[] is the active tool length offset vector.
        void forward(const float* part, float bDeg, const float* tlo, float* mach) const;
        void inverse(const float* mach, float bDeg, const float* tlo, float* part) const;

        // ---- TCP modal state -------------------------------------------------
        void setTcp(bool on) { _tcp_active = on; }
        bool tcpActive() const { return _tcp_active; }
        void setSuspended(bool s) { _suspended = s; }
        // NOT const: it logs, and KinematicSystem::name() is non-const.
        void reorientOffset(const float* oldOffsets, float* newOffsets);
        bool transformEnabled() const { return _tcp_active && !_suspended; }

        axis_t rotaryAxis() const { return _rot_index; }
        float  rotaryOffset() const;

    protected:
        ~TCPCartesian() {}

    private:
        // A point on the rotary axis, machine coordinates. Any point on the
        // axis line will do. Produced by Macros/Probing/ProbeBAxisCal.nc.
        float _pivot_x = 0.0f;
        float _pivot_y = 0.0f;
        float _pivot_z = 0.0f;

        // Unit vector along the rotary axis, machine frame. (0,1,0) is a
        // perfectly aligned axis. Normalised in afterParse().
        float _axis_x = 0.0f;
        float _axis_y = 1.0f;
        float _axis_z = 0.0f;

        // ISO table convention: phi = -beta, so at B+90 the face that was on
        // part +X ends up pointing at the spindle. Verified on this machine,
        // so it is a constant rather than a config item. If a rebuild ever
        // reverses the rotary, flip direction_invert on the axis instead --
        // that keeps reported position, soft limits and the post in step.
        static constexpr int ROT_SIGN = -1;

        // Which axis the rotary is on. NOT a config item: it is discovered
        // from the axis tree at init, so whatever you declared in config.yaml
        // is what gets used. See findRotaryAxis().
        axis_t _rot_index = INVALID_AXIS;

        // Segmentation, for moves that actually change B.
        // sagitta ~= r * dB_rad^2 / 8
        float _seg_len_mm   = 1.0f;
        float _seg_ang_deg  = 0.8f;
        int32_t _max_segments = 20000;

        bool  _scale_feed     = true;
        float _max_feed_scale = 10.0f;

        // false: the rotary carries the PART. The tool vector is fixed in the
        //        machine frame, so the tool length offset is stripped before
        //        rotating and re-added afterwards. This machine.
        // true:  the rotary tilts the HEAD. The tool vector rotates with it.
        bool _rotate_tlo = false;

        bool _check_soft_limits = true;

        bool  _tcp_active = false;  // M128 / M129
        bool  _suspended  = false;  // G53 block, homing, parking

        bool findRotaryAxis();
        void  rotateAboutAxis(const float* v, float phi, float* out) const;
        void toolOffset(float* tlo) const;
        bool outOfTravel(const float* motors, axis_t n_axis, bool raise) const;
    };

    // -----------------------------------------------------------------------
    // TCP control surface used by the M128 / M129 handlers in GCode.cpp.
    // These are free functions so that neither Kinematics.h nor Cartesian.h
    // has to change. They return false if the machine is not configured with
    // TCPCartesian, which lets M128 raise a proper gcode error rather
    // than silently doing nothing.
    // -----------------------------------------------------------------------
    bool tcp_supported();
    bool tcp_set(bool on);
    bool tcp_is_active();
    void tcp_suspend(bool suspended);  // for the duration of one G53 block
    // A work offset is about to be rewritten. If its ROTARY component is
    // changing, the part's reference orientation is moving, so the XYZ
    // component is rotated to match and the physical origin stays put.
    void tcp_reorient_offset(const float* oldOffsets, float* newOffsets);

}