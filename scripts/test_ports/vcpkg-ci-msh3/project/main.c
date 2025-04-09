#include <msh3.h>

int main()
{
    MSH3_API* api = MsH3ApiOpen();
    if (api)
        MsH3ApiClose(api);
}
