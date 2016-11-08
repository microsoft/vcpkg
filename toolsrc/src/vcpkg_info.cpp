#include "vcpkg_info.h"
#include "metrics.h"

#define STRINGIFY(X) #X
#define MACRO_TO_STRING(X) STRINGIFY(X)

#define VCPKG_VERSION_AS_STRING MACRO_TO_STRING(VCPKG_VERSION)"" // Double quotes needed at the end to prevent blank token

namespace vcpkg { namespace Info
{
    const std::string& version()
    {
        static const std::string s_version =
#include "../VERSION.txt"
            

#pragma warning( push )
#pragma warning( disable : 4003)
            // VCPKG_VERSION can be defined but have no value, which yields C4003.
            + std::string(VCPKG_VERSION_AS_STRING)
#pragma warning( pop )
#ifndef NDEBUG
            + std::string("-debug")
#endif
            + std::string(GetCompiledMetricsEnabled() ? "" : "-external");
        return s_version;
    }

    const std::string& email()
    {
        static const std::string s_email = R"(vcpkg@microsoft.com)";
        return s_email;
    }
}}
