#include <raqm.h>

int main(void)
{
    raqm_t* raqm = raqm_create();
    if (raqm == 0) {
        return 1;
    }

    raqm_destroy(raqm);
    return 0;
}
