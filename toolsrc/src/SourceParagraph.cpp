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

    namespace SourceParagraphOptionalField
    {
        static const std::string DESCRIPTION = "Description";
        static const std::string MAINTAINER = "Maintainer";
        static const std::string BUILD_DEPENDS = "Build-Depends";
    }

    const std::vector<std::string>& SourceParagraph::get_list_of_valid_fields()
    {
        static const std::vector<std::string> valid_fields =
        {
            SourceParagraphRequiredField::SOURCE,
            SourceParagraphRequiredField::VERSION,

            SourceParagraphOptionalField::DESCRIPTION,
            SourceParagraphOptionalField::MAINTAINER,
            SourceParagraphOptionalField::BUILD_DEPENDS
        };

        return valid_fields;
    }

    SourceParagraph::SourceParagraph() = default;

    SourceParagraph::SourceParagraph(std::unordered_map<std::string, std::string> fields)
    {
        using namespace vcpkg::details;
        this->name = remove_required_field(&fields, SourceParagraphRequiredField::SOURCE);
        this->version = remove_required_field(&fields, SourceParagraphRequiredField::VERSION);
        this->description = remove_optional_field(&fields, SourceParagraphOptionalField::DESCRIPTION);
        this->maintainer = remove_optional_field(&fields, SourceParagraphOptionalField::MAINTAINER);

        std::string deps = remove_optional_field(&fields, SourceParagraphOptionalField::BUILD_DEPENDS);
        this->depends = parse_depends(deps);

        this->unparsed_fields = std::move(fields);
    }
}
