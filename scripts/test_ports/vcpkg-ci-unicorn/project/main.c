#include <unicorn/unicorn.h>

int main()
{
    uc_engine* uc;
    uc_open(UC_ARCH_X86, UC_MODE_32, &uc);
    return 0;
}
