#include <libmem/libmem.h>
int main()
{
   lm_module_t moduled;
   LM_FindModule("user32.dll", &moduled);
   return 0;
}
