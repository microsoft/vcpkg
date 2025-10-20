#include <stdio.h>
#include <srtp2/srtp.h>

int main()
{
    printf("libsrtp versions: %s\n", srtp_get_version_string());
    return 0;
}
