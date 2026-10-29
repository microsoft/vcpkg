#include <stdio.h>
#include <minc2.h>

int main()
{
    int result;
    mihandle_t hvol;

    result = miopen_volume("/tmp/test.mnc", MI2_OPEN_READ, &hvol);
    if (result != MI_NOERROR) {
        fprintf(stderr, "Error opening the input file.\n");
    }

    miclose_volume(hvol);
    return 0;
}
