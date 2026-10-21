#include <mpg123.h>

int main()
{
	mpg123_handle *m = mpg123_new(NULL, NULL);
	mpg123_open(m, "vcpkg");
	mpg123_scan(m);
	mpg123_close(m);
	mpg123_delete(m);
    return 0;
}
