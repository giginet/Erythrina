#pragma once

#include "pd_api.h"

/// Global variable that will be populated by the Playdate runtime before
/// program execution.
extern PlaydateAPI* playdate;

void call_log_to_console(void *fn_ptr, const char *msg);
