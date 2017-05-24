#pragma once

#include <unordered_map>
#include <vector>

namespace vcpkg
{
    struct Triplet;

    struct Dependency
    {
        std::string name;
        std::string qualifier;
    };

    const std::string& to_string(const Dependency& dep);

    /// <summary>
    /// Port metadata (CONTROL file)
    /// </summary>
    struct SourceParagraph
    {
        SourceParagraph();

        explicit SourceParagraph(std::unordered_map<std::string, std::string> fields);

        std::string name;
        std::string version;
        std::string description;
        std::string maintainer;
        std::vector<Dependency> depends;
    };

    std::vector<std::string> filter_dependencies(const std::vector<Dependency>& deps, const Triplet& t);

    std::vector<Dependency> expand_qualified_dependencies(const std::vector<std::string>& depends);
    std::vector<std::string> parse_depends(const std::string& depends_string);
}
