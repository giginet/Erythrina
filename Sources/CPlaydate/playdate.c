#include "pd_api.h"

/// Global variable that will be populated by the Playdate runtime before
/// program execution.
PlaydateAPI* playdate;

void call_log_to_console(void *fn_ptr, const char *msg) {
    typedef void (*log_fn_t)(const char *fmt, ...);
    log_fn_t fn = (log_fn_t)fn_ptr;
    fn("%s", msg);
}
