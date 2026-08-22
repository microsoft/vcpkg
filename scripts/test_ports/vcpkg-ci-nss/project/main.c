#include <nss.h>

int main()
{
    const char* configdir = "./DONOTUSE";
    SECStatus rv = NSS_Initialize(configdir, "", "", SECMOD_DB, NSS_INIT_NOROOTINIT | NSS_INIT_OPTIMIZESPACE);
    NSS_Shutdown();
    return 0;
}
