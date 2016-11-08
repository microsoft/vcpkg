#include "vcpkg.h"
#include <regex>

namespace vcpkg
{
    std::string shorten_description(const std::string& desc)
    {
        auto simple_desc = std::regex_replace(desc.substr(0, 49), std::regex("\\n( |\\t)?"), "");
        if (desc.size() > 49)
            simple_desc.append("...");
        return simple_desc;
    }
}
