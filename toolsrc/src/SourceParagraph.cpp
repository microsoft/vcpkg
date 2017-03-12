#include "pch.h"
#include "SourceParagraph.h"
#include "vcpkglib_helpers.h"
#include "vcpkg_System.h"
#include "vcpkg_Maps.h"
#include "triplet.h"

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

    static const std::vector<std::string>& get_list_of_valid_fields()
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
        this->depends = expand_qualified_dependencies(parse_depends(deps));

        if (!fields.empty())
        {
            const std::vector<std::string> remaining_fields = Maps::extract_keys(fields);
            const std::vector<std::string>& valid_fields = get_list_of_valid_fields();

            const std::string remaining_fields_as_string = Strings::join("\n    ", remaining_fields);
            const std::string valid_fields_as_string = Strings::join("\n    ", valid_fields);

            System::println(System::color::error, "Error: There are invalid fields in the Source Paragraph of %s", this->name);
            System::println("The following fields were not expected:\n\n    %s\n\n", remaining_fields_as_string);
            System::println("This is the list of valid fields (case-sensitive): \n\n    %s\n", valid_fields_as_string);
            exit(EXIT_FAILURE);
        }
    }

    std::vector<dependency> vcpkg::expand_qualified_dependencies(const std::vector<std::string>& depends)
    {
        auto convert = [&](const std::string& depend_string) -> dependency {
            auto pos = depend_string.find(' ');
            if (pos == std::string::npos)
                return{ depend_string, "" };
            // expect of the form "\w+ \[\w+\]"
            dependency dep;
            dep.name = depend_string.substr(0, pos);
            if (depend_string.c_str()[pos + 1] != '[' || depend_string[depend_string.size() - 1] != ']')
            {
                // Error, but for now just slurp the entire string.
                return{ depend_string, "" };
            }
            dep.qualifier = depend_string.substr(pos + 2, depend_string.size() - pos - 3);
            return dep;
        };

        std::vector<vcpkg::dependency> ret;

        for (auto&& depend_string : depends)
        {
            ret.push_back(convert(depend_string));
        }

        return ret;
    }

    std::vector<std::string> parse_depends(const std::string& depends_string)
    {
        if (depends_string.empty())
        {
            return{};
        }

        std::vector<std::string> out;

        size_t cur = 0;
        do
        {
            auto pos = depends_string.find(',', cur);
            if (pos == std::string::npos)
            {
                out.push_back(depends_string.substr(cur));
                break;
            }
            out.push_back(depends_string.substr(cur, pos - cur));

            // skip comma and space
            ++pos;
            if (depends_string[pos] == ' ')
            {
                ++pos;
            }

            cur = pos;
        } while (cur != std::string::npos);

        return out;
    }

    std::vector<std::string> filter_dependencies(const std::vector<vcpkg::dependency>& deps, const triplet& t)
    {
        std::vector<std::string> ret;
        for (auto&& dep : deps)
        {
            if (dep.qualifier.empty() || t.canonical_name().find(dep.qualifier) != std::string::npos)
            {
                ret.push_back(dep.name);
            }
        }
        return ret;
    }

    std::ostream & operator<<(std::ostream & os, const dependency & p)
    {
        os << p.name;
        return os;
    }
}
