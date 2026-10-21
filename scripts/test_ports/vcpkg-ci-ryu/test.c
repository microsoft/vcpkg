#include <string.h>
#include <stdio.h>

#include <ryu/ryu.h>
#include <ryu/ryu2.h>

int main() {
    char* result = d2s(3.14);
    if (strcmp(result, "3.14E0") != 0) {
        printf("Unexpected ryu: %s\n", result);
        return 1;
    }

    result = d2fixed(3.14159, 1);
    if (strcmp(result, "3.1") != 0) {
        printf("Unexpected ryu_printf: %s\n", result);
        return 2;
    }

    return 0;
}
