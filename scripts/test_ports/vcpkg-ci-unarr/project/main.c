#include <unarr.h>
int main()
{
   ar_stream *stream;
   ar_archive *ar = ar_open_rar_archive(stream);
   ar_close_archive(ar);
   return 0;
}
