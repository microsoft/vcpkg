#pragma once
#include <string>

namespace vcpkg::PostBuildLint
{
    enum class LinkageType
    {
        DYNAMIC,
        STATIC,
        UNKNOWN
    };

    LinkageType linkage_type_value_of(const std::string& as_string);

    std::string to_string(const LinkageType& build_info);
}
