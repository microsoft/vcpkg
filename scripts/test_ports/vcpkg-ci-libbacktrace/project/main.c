#include <backtrace.h>
int main()
{
    backtrace_create_state(NULL, 0, NULL, NULL);
    return 0;
}
