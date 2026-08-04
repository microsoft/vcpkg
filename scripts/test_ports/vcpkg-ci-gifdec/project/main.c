#include <gifdec.h>
int main()
{
   gd_GIF *gif;
   gif = gd_open_gif("test.gif");
   gd_close_gif(gif);
   return 0;
}
