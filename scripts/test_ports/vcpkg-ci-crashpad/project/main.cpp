#include "client/crashpad_client.h"

int main()
{
    auto *client = new crashpad::CrashpadClient();
    return 0;
}
