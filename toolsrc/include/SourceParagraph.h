#pragma once

#include <vector>
#include <unordered_map>

namespace vcpkg
{
    struct triplet;

    struct dependency
    {
        std::string name;
        std::string qualifier;
    };

    std::ostream& operator<<(std::ostream& os, const dependency& p);

    struct SourceParagraph
    {
        SourceParagraph();

        explicit SourceParagraph(std::unordered_map<std::string, std::string> fields);

        std::string name;
        std::string version;
        std::string description;
        std::string maintainer;
        std::vector<dependency> depends;
    };

    std::vector<std::string> filter_dependencies(const std::vector<vcpkg::dependency>& deps, const triplet& t);

    std::vector<vcpkg::dependency> expand_qualified_dependencies(const std::vector<std::string>& depends);
    std::vector<std::string> parse_depends(const std::string& depends_string);
}
