#pragma once

#include <vector>
#include <unordered_map>

namespace vcpkg
{
    struct SourceParagraph
    {
        static const std::vector<std::string>& get_list_of_valid_fields();

        SourceParagraph();

        explicit SourceParagraph(std::unordered_map<std::string, std::string> fields);

        std::string name;
        std::string version;
        std::string description;
        std::string maintainer;
        std::vector<std::string> depends;
        std::unordered_map<std::string, std::string> unparsed_fields;
    };
}
