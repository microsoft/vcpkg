#include "metrics.h"
#include "vcpkg_Checks.h"
#include "vcpkg_Files.h"
#include <Windows.h>

using namespace vcpkg;

int WINAPI
WinMain(
    _In_ HINSTANCE hInstance,
         _In_opt_ HINSTANCE hPrevInstance,
         _In_ LPSTR lpCmdLine,
         _In_ int nShowCmd
)
{
    LPWSTR* szArgList;
    int argCount;

    szArgList = CommandLineToArgvW(GetCommandLineW(), &argCount);

    Checks::check_exit(argCount == 2, "Requires exactly one argument, the path to the payload file");
    Upload(Files::read_contents(szArgList[1]).get_or_throw());
}
