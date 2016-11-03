#include "SourceParagraph.h"
#include "vcpkglib_helpers.h"

using namespace vcpkg::details;

vcpkg::SourceParagraph::SourceParagraph() = default;

vcpkg::SourceParagraph::SourceParagraph(const std::unordered_map<std::string, std::string>& fields):
    name(required_field(fields, "Source")),
    version(required_field(fields, "Version")),
    description(optional_field(fields, "Description")),
    maintainer(optional_field(fields, "Maintainer"))
{
    std::string deps = optional_field(fields, "Build-Depends");
    this->depends = parse_depends(deps);
}
