#define CATCH_CONFIG_RUNNER
#include <catch2/catch.hpp>

#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/system.h>

int main(int argc, char** argv)
{
    if (vcpkg::System::get_environment_variable("VCPKG_DEBUG").value_or("") == "1") vcpkg::Debug::g_debugging = true;

    return Catch::Session().run(argc, argv);
}
