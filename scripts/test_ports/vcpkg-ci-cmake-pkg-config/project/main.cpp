#include <stdio.h>
#include <zlib.h>

int main()
{
  unsigned char strsrc[] = "0123456789abcdefghigklmnopqrstuvwxyz;/,.";
  unsigned char buf[1024] = { 0 };
  unsigned char strdst[1024] = { 0 };
  unsigned long srclen = sizeof(strsrc);
  unsigned long buflen = sizeof(buf);
  unsigned long dstlen = sizeof(strdst);
  FILE * fp;
 
  for(int i = 0; i < srclen; ++i)
  {
      printf("%c", strsrc[i]);
  }
  compress(buf, &buflen, strsrc, srclen);
  uncompress(strdst, &dstlen, buf, buflen);
 
  for(int i = 0; i < dstlen; ++i)
  {
      printf("%c", strdst[i]);
  }
 
  return 0;
}