#include <gwenhywfar/gwenhywfar.h>  /* based on gwenhywfar.pc */

int main()
{
    int result = GWEN_Init();
    GWEN_Fini();
    return result;
}
