#include "SourceParagraph.h"
#include "vcpkglib_helpers.h"

using namespace vcpkg::details;

vcpkg::SourceParagraph::SourceParagraph() = default;

vcpkg::SourceParagraph::SourceParagraph(const std::unordered_map<std::string, std::string>& fields)
{
    required_field(fields, name, "Source");
    required_field(fields, version, "Version");
    optional_field(fields, description, "Description");
    std::string deps;
    optional_field(fields, deps, "Build-Depends");
    if (!deps.empty())
    {
        depends.clear();
        parse_depends(deps, depends);
    }
    optional_field(fields, maintainer, "Maintainer");
}
