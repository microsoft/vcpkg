#include <freerdp/freerdp.h>

int main(void)
{
	const char* version = freerdp_get_version_string();
	return (version != NULL) ? 0 : 1;
}
