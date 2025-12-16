#include <svn_client.h>
#include <svn_version.h>

int main()
{
    const svn_version_t *version = svn_client_version();
    return 0;
}
