#pragma once

#include <vector>
#include <unordered_map>

namespace vcpkg
{
    struct SourceParagraph
    {
        SourceParagraph();

        explicit SourceParagraph(const std::unordered_map<std::string, std::string>& fields);

        std::string name;
        std::string version;
        std::string description;
        std::string maintainer;
        std::vector<std::string> depends;
    };
}
