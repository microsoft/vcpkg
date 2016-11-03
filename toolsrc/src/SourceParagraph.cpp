#include "SourceParagraph.h"
#include "vcpkglib_helpers.h"
#include "vcpkg_System.h"
#include "vcpkg_Maps.h"

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
        this->name = details::remove_required_field(&fields, SourceParagraphRequiredField::SOURCE);
        this->version = details::remove_required_field(&fields, SourceParagraphRequiredField::VERSION);
        this->description = details::remove_optional_field(&fields, SourceParagraphOptionalField::DESCRIPTION);
        this->maintainer = details::remove_optional_field(&fields, SourceParagraphOptionalField::MAINTAINER);

        std::string deps = details::remove_optional_field(&fields, SourceParagraphOptionalField::BUILD_DEPENDS);
        this->depends = details::parse_depends(deps);

        if (!fields.empty())
        {
            const std::vector<std::string> remaining_fields = Maps::extract_keys(fields);
            const std::vector<std::string>& valid_fields = get_list_of_valid_fields();

            const std::string remaining_fields_as_string = Strings::join(remaining_fields, "\n    ");
            const std::string valid_fields_as_string = Strings::join(valid_fields, "\n    ");

            System::println(System::color::error, "Error: There are invalid fields in the Source Paragraph of %s", this->name);
            System::println("The following fields were not expected:\n\n    %s\n\n", remaining_fields_as_string);
            System::println("This is the list of valid fields (case-sensitive): \n\n    %s\n", valid_fields_as_string);
            exit(EXIT_FAILURE);
        }
    }
}
