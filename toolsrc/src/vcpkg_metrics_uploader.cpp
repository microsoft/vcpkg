#include "metrics.h"
#include "vcpkg_Checks.h"
#include "vcpkg_Files.h"
#include <Windows.h>

using namespace vcpkg;

int WINAPI WinMain(_In_ HINSTANCE, _In_opt_ HINSTANCE, _In_ LPSTR, _In_ int)
{
    LPWSTR* szArgList;
    int argCount;

    szArgList = CommandLineToArgvW(GetCommandLineW(), &argCount);

    Checks::check_exit(VCPKG_LINE_INFO, argCount == 2, "Requires exactly one argument, the path to the payload file");
    Upload(Files::read_contents(szArgList[1]).value_or_exit(VCPKG_LINE_INFO));
}
