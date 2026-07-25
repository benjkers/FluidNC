// Copyright (c) 2024 - Mitch Bradley
// Use of this source code is governed by a GPLv3 license that can be found in the LICENSE file.

#pragma once

#include <stddef.h>
#include <string>

#include <cstdint>
// TODO - make ngc_param_id_t an enum, give names to numbered parameters where
// possible
typedef uint32_t ngc_param_id_t;

bool assign_param(const char* line, size_t& pos);
bool read_number(const char* line, size_t& pos, float& value /*, bool in_expression = false*/);
bool read_number(const std::string_view sv, float& value /*, bool in_expression = false*/);
bool perform_assignments();
bool named_param_exists(std::string& name);
bool set_named_param(const char* name, float value);
bool set_numbered_param(ngc_param_id_t, float value);

// Read back a global (underscore-prefixed) named parameter that was set by
// gcode, e.g. from within a running macro. Used by modules that need to
// bridge a value computed in gcode back into C++, since macros run
// asynchronously relative to the C++ code that queued them.
bool get_global_named_param(const std::string& name, float& value);

// Forward declarations
class Channel;

// List global parameters
void list_global_params(Channel& out);

// Forward declaration for list_named_parameters
#include <map>
extern std::map<std::string, float> global_named_params;
