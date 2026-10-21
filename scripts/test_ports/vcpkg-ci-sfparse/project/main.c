#include <sfparse/sfparse.h>

int main(void) {
    sfparse_parser sfp;
    const uint8_t data[] = {0};
    sfparse_parser_init(&sfp, data, 0);
    return 0;
}
