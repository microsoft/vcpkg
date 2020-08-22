#include <vcpkg/base/system_headers.h>

#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>

#include <vcpkg/metrics.h>

#include <shellapi.h>

using namespace vcpkg;

int WINAPI WinMain(_In_ HINSTANCE, _In_opt_ HINSTANCE, _In_ LPSTR, _In_ int)
{
    int argCount;
    LPWSTR* szArgList = CommandLineToArgvW(GetCommandLineW(), &argCount);

    Checks::check_exit(VCPKG_LINE_INFO, argCount == 2, "Requires exactly one argument, the path to the payload file");
    auto v = Files::get_real_filesystem().read_contents(szArgList[1]).value_or_exit(VCPKG_LINE_INFO);
    Metrics::g_metrics.lock()->upload(v);
    LocalFree(szArgList);
    return 0;
}
