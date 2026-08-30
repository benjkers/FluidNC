// ProbeLog.cpp
//
// Appends probing results to a CSV file on the SD card, and clears it.
//
// WHY A COMMAND WITH NO ARGUMENTS
//   A line beginning with '$' is handled by the settings dispatcher, NOT by
//   the gcode parser, so #<param> references in it are never interpolated --
//   "$Probe/Log=#<_probe_meas_x>" would write that text literally. The values
//   therefore have to be read here, out of global_named_params, rather than
//   passed on the command line. That is the opposite of how $ATC/SaveGauge
//   works, because the ATC already holds its values in C++.
//
// COMMANDS
//   $Probe/Log        append one row for the measurement just taken
//   $Probe/LogClear   delete the log and start again
//   $Probe/LogShow    print the log to the console
//
// The probing macros set #<_probe_log_kind> to identify the feature, then
// issue $Probe/Log. Everything else is read from the parameters the macros
// have already computed.
//
// Registered in ProcessSettings.cpp -- see the snippet at the bottom.

#include "Machine/MachineConfig.h"
#include "FluidPath.h"
#include "Parameters.h"
#include "Settings.h"
#include <cstdio>
#include <cstring>
#include <string>
#include <sys/stat.h>

namespace {
    const char* LOG_PATH = "/probe_log.csv";
    const char* BAK_PATH = "/probe_log.bak";

    // Roll over at this size rather than growing without bound. One row is
    // about 160 bytes, so this is a few thousand measurements -- enough to
    // cover a job comfortably while staying trivial to open in a spreadsheet.
    const long MAX_BYTES = 256L * 1024L;

    const char* HEADER =
        "seq,uptime_s,program,feature,wcs,"
        "nom_x,nom_y,nom_z,meas_x,meas_y,meas_z,"
        "nom_size,meas_size,dev_size,dev_pos,tol_size,tol_pos,result,runout\n";

    // Sequence continues across a reboot by counting the rows already
    // present, which matters because the ESP32 has no clock to order by.
    long g_seq      = -1;
    bool g_seq_read = false;

    // get_global_named_param() is what the ATC uses to read #<_atc_measured_z>
    // back after a probe, so the same accessor is used here rather than
    // reaching into global_named_params directly.
    bool get_param(const char* name, float& out) { return get_global_named_param(name, out); }

    float param_or(const char* name, float dflt) {
        float v;
        return get_param(name, v) ? v : dflt;
    }

    // A blank cell is more honest than a zero for a value the cycle never
    // measured -- a Z probe has no size, and 0.0000 would look like one.
    void write_num(FILE* f, const char* name) {
        float v;
        if (get_param(name, v)) {
            fprintf(f, "%.4f,", v);
        } else {
            fprintf(f, ",");
        }
    }

    const char* feature_name(int kind) {
        switch (kind) {
            case 1:  return "Z";
            case 2:  return "XEDGE";
            case 3:  return "YEDGE";
            case 4:  return "XCHAN";
            case 5:  return "YCHAN";
            case 6:  return "XWALL";
            case 7:  return "YWALL";
            case 8:  return "BORE";
            case 9:  return "BOSS";
            case 10: return "PHOLE";
            case 11: return "PBOSS";
            // Yaw calibration reuses the generic columns rather than earning
            // its own writer: one row per opposite pair, then a summary.
            //   YAWCAL  nom_size = ideal separation, meas_size = measured,
            //           dev_size = that pair's pre-travel, meas_x = angle
            //   YAWSUM  nom_size = min, meas_size = max,
            //           dev_size = mean pre-travel, dev_pos = eccentricity
            case 12: return "YAWCAL";
            case 13: return "YAWSUM";
            default: return "?";
        }
    }

    // Reports the same verdict the macros act on, so the log and the machine
    // never disagree about whether something passed.
    const char* verdict() {
        float tol_s = param_or("_probe_tol_size", 0.0f);
        float tol_p = param_or("_probe_tol_pos", 0.0f);
        float dev_s = param_or("_probe_dev_size", 0.0f);
        float dev_p = param_or("_probe_dev_pos", 0.0f);

        bool bad_size = (tol_s > 0.0f) && (fabsf(dev_s) > tol_s);
        bool bad_pos  = (tol_p > 0.0f) && (dev_p > tol_p);

        if (bad_size && bad_pos) return "BOTH";
        if (bad_size)            return "SIZE";
        if (bad_pos)             return "POS";
        return "PASS";
    }

    long file_size(const char* path) {
        struct stat st;
        return (stat(path, &st) == 0) ? long(st.st_size) : -1;
    }

    long count_rows(const char* path) {
        FILE* f = fopen(path, "r");
        if (!f) {
            return 0;
        }
        long n = 0;
        int  c;
        while ((c = fgetc(f)) != EOF) {
            if (c == '\n') {
                ++n;
            }
        }
        fclose(f);
        return n > 0 ? n - 1 : 0;  // discount the header
    }
}

// $Probe/Log
Error probe_log_append(const char* value, AuthenticationLevel auth_level, Channel& out) {
    std::error_code ec;
    FluidPath       dir("/", SD, ec);
    if (ec) {
        log_error("Probe log: SD card not available");
        return Error::FsFailedMount;
    }
    std::string path = std::string(dir.c_str()) + LOG_PATH;
    std::string bak  = std::string(dir.c_str()) + BAK_PATH;

    // Roll over before appending, so the cap is never exceeded. One previous
    // generation is kept; anything older is dropped deliberately.
    long sz = file_size(path.c_str());
    if (sz >= MAX_BYTES) {
        remove(bak.c_str());
        rename(path.c_str(), bak.c_str());
        log_info("Probe log: reached " << MAX_BYTES << " bytes, rolled over to " << BAK_PATH);
        g_seq_read = false;
    }

    bool  fresh = (file_size(path.c_str()) < 0);
    FILE* f     = fopen(path.c_str(), "a");
    if (!f) {
        log_error("Probe log: cannot open " << path.c_str());
        return Error::FsFailedOpenFile;
    }
    if (fresh) {
        fputs(HEADER, f);
    }

    if (!g_seq_read) {
        g_seq      = count_rows(path.c_str());
        g_seq_read = true;
    }

    int kind = int(param_or("_probe_log_kind", 0.0f));

    fprintf(f, "%ld,", ++g_seq);
    fprintf(f, "%lu,", (unsigned long)(millis() / 1000));
    fprintf(f, "%d,", int(param_or("_probe_prog_id", 0.0f)));
    fprintf(f, "%s,", feature_name(kind));
    fprintf(f, "%d,", int(param_or("_probe_wcs", 0.0f)));

    write_num(f, "_probe_nom_x");
    write_num(f, "_probe_nom_y");
    write_num(f, "_probe_nom_z");
    write_num(f, "_probe_log_x");
    write_num(f, "_probe_log_y");
    write_num(f, "_probe_log_z");
    write_num(f, "_probe_log_nomsize");
    write_num(f, "_probe_log_size");
    write_num(f, "_probe_dev_size");
    write_num(f, "_probe_dev_pos");
    write_num(f, "_probe_tol_size");
    write_num(f, "_probe_tol_pos");

    fprintf(f, "%s,", verdict());
    fprintf(f, "%.4f\n", param_or("_probe_runout", 0.0f));

    fclose(f);
    log_info("Probe log: row " << g_seq << " " << feature_name(kind) << " " << verdict());
    return Error::Ok;
}

// $Probe/LogClear
Error probe_log_clear(const char* value, AuthenticationLevel auth_level, Channel& out) {
    std::error_code ec;
    FluidPath       dir("/", SD, ec);
    if (ec) {
        log_error("Probe log: SD card not available");
        return Error::FsFailedMount;
    }
    std::string path = std::string(dir.c_str()) + LOG_PATH;
    std::string bak  = std::string(dir.c_str()) + BAK_PATH;

    bool had = (file_size(path.c_str()) >= 0);
    remove(path.c_str());

    // Only clear the rolled-over generation when explicitly asked, so a
    // routine clear between parts cannot silently discard older results.
    if (value && (strcasecmp(value, "all") == 0)) {
        remove(bak.c_str());
        log_info("Probe log: cleared, including the rolled-over copy");
    } else {
        // Not a ternary inside log_info(): the macro expands to "ss << x", and
        // << binds tighter than ?:, so the whole thing parses as
        // (ss << had) ? ... : ... and fails to compile.
        if (had) {
            log_info("Probe log: cleared");
        } else {
            log_info("Probe log: nothing to clear");
        }
    }
    g_seq      = 0;
    g_seq_read = true;
    return Error::Ok;
}

// $Probe/LogShow
Error probe_log_show(const char* value, AuthenticationLevel auth_level, Channel& out) {
    std::error_code ec;
    FluidPath       dir("/", SD, ec);
    if (ec) {
        log_error("Probe log: SD card not available");
        return Error::FsFailedMount;
    }
    std::string path = std::string(dir.c_str()) + LOG_PATH;
    FILE*       f    = fopen(path.c_str(), "r");
    if (!f) {
        log_info("Probe log: no log file yet");
        return Error::Ok;
    }
    char line[220];
    while (fgets(line, sizeof(line), f)) {
        line[strcspn(line, "\r\n")] = '\0';
        log_stream(out, line);
    }
    fclose(f);
    return Error::Ok;
}

// ---------------------------------------------------------------------------
// Registration, in make_user_commands() in ProcessSettings.cpp, beside the
// existing $ATC/SaveGauge line and following the same form:
//
//     new UserCommand(NULL, "Probe/Log", probe_log_append, anyState);
//     new UserCommand(NULL, "Probe/LogClear", probe_log_clear, anyState);
//     new UserCommand(NULL, "Probe/LogShow", probe_log_show, anyState);
//
// with these beside the other externs near the top:
//
//     extern Error probe_log_append(const char*, AuthenticationLevel, Channel&);
//     extern Error probe_log_clear(const char*, AuthenticationLevel, Channel&);
//     extern Error probe_log_show(const char*, AuthenticationLevel, Channel&);
//
// NULL for the short alias, matching $ATC/SaveGauge -- these are only ever
// typed or issued by name, so a two-letter code would just be another thing
// to collide with ("PL" is already Parameters/List).
//
// anyState matters more than it looks. $Probe/Log is issued from inside a
// RUNNING macro, so the machine is in Cycle, not Idle. $ATC/SaveGauge is
// called the same way and uses anyState for exactly this reason.
// ---------------------------------------------------------------------------