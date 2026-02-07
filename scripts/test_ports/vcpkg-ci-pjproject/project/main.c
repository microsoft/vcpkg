#include <stdio.h>
#include <pjlib.h>

int main()
{
    printf("pjlib version: %s\n", pj_get_version());
    return 0;
}