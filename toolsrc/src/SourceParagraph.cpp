#include "SourceParagraph.h"
#include "vcpkglib_helpers.h"

namespace vcpkg
{
    //
    namespace SourceParagraphRequiredField
    {
        static const std::string SOURCE = "Source";
        static const std::string VERSION = "Version";
    }

    namespace SourceParagraphOptionalEntry
    {
        static const std::string DESCRIPTION = "Description";
        static const std::string MAINTAINER = "Maintainer";
        static const std::string BUILD_DEPENDS = "Build-Depends";
    }

    const std::vector<std::string>& SourceParagraph::get_list_of_valid_entries()
    {
        static const std::vector<std::string> valid_enties =
        {
            SourceParagraphRequiredField::SOURCE,
            SourceParagraphRequiredField::VERSION,

            SourceParagraphOptionalEntry::DESCRIPTION,
            SourceParagraphOptionalEntry::MAINTAINER,
            SourceParagraphOptionalEntry::BUILD_DEPENDS
        };

        return valid_enties;
    }

    SourceParagraph::SourceParagraph() = default;

    SourceParagraph::SourceParagraph(std::unordered_map<std::string, std::string> fields)
    {
        using namespace vcpkg::details;
        this->name = remove_required_field(&fields, SourceParagraphRequiredField::SOURCE);
        this->version = remove_required_field(&fields, SourceParagraphRequiredField::VERSION);
        this->description = remove_optional_field(&fields, SourceParagraphOptionalEntry::DESCRIPTION);
        this->maintainer = remove_optional_field(&fields, SourceParagraphOptionalEntry::MAINTAINER);

        std::string deps = remove_optional_field(&fields, SourceParagraphOptionalEntry::BUILD_DEPENDS);
        this->depends = parse_depends(deps);

        this->unparsed_fields = std::move(fields);
    }
}
