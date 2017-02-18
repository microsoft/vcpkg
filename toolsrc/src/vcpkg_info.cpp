#include "pch.h"
#include "vcpkg_info.h"

namespace vcpkg::Info
{
    const std::string& email()
    {
        static const std::string s_email = R"(vcpkg@microsoft.com)";
        return s_email;
    }
}
