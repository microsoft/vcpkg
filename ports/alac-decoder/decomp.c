#include "decomp.h"
#include <stdint.h>

int set_endian()
{
    uint32_t integer = 0x000000aa;
    unsigned char *p = (unsigned char*)&integer;

    if (p[0] == 0xaa) return  0;
    else return  1;
}
