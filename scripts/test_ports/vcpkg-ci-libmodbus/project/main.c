#include <stdio.h>
#include <modbus.h>

int main()
{
    modbus_t *ctx = modbus_new_rtu("/dev/ttyUSB0", 115200, 'N', 8, 1);
    if (ctx == NULL) {
        fprintf(stderr, "Unable to create the libmodbus context\n");
        return -1;
    }
    return 0;
}
