#include <mimalloc.h>
#include <stdio.h>

int main()
{
    printf("mimalloc version: %d\n", mi_version());
    return 0;
}
