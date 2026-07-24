#ifdef WIN32
#undef WIN32
#endif

#include <flann/flann.h>

#include <stdio.h>

int main(void) {
    flann_build_index(NULL, 0, 0, NULL, NULL);

    return 0;
}
