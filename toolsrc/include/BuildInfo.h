#pragma once

#include <unordered_map>
#include "Paragraphs.h"

namespace fs = std::tr2::sys;

namespace vcpkg
{
    enum class LinkageType
    {
        DYNAMIC,
        STATIC,
        UNKNOWN
    };

    LinkageType linkage_type_value_of(const std::string& as_string);

    struct BuildInfo
    {
        static BuildInfo create(const std::unordered_map<std::string, std::string>& pgh);

        std::string crt_linkage;
        std::string library_linkage;
    };

    BuildInfo read_build_info(const fs::path& filepath);
}
