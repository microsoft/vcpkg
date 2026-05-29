#include <stdio.h>
#include <box2d/box2d.h>

int main()
{
    b2Version version = b2GetVersion();
    printf("b2 version: %d.%d.%d\n", version.major, version.minor, version.revision);

    b2WorldDef worldDef = b2DefaultWorldDef();
    return 0;
}
