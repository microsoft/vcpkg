#define CATCH_CONFIG_RUNNER
#include <vcpkg-test/catch.h>

#include <vcpkg/base/system.debug.h>

int main(int argc, char** argv)
{
    vcpkg::Debug::g_debugging = true;

    return Catch::Session().run(argc, argv);
}
