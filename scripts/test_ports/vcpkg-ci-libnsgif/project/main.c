#include <nsgif.h>

int main(void)
{
   const nsgif_bitmap_cb_vt bitmap_vt = { 0 };
   nsgif_t *gif = NULL;
   const nsgif_error err = nsgif_create(&bitmap_vt, NSGIF_BITMAP_FMT_R8G8B8A8, &gif);
   if (err != NSGIF_OK) {
      return 1;
   }
   nsgif_destroy(gif);
   return 0;
}
