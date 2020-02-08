#include "pch.h"

#include <vcpkg/logicexpression.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/sourceparagraph.h>
#include <vcpkg/triplet.h>

#include <vcpkg/base/checks.h>
#include <vcpkg/base/expected.h>
#include <vcpkg/base/span.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>

namespace vcpkg
{
    using namespace vcpkg::Parse;

    namespace SourceParagraphFields
    {
        static const std::string BUILD_DEPENDS = "Build-Depends";
        static const std::string DEFAULTFEATURES = "Default-Features";
        static const std::string DESCRIPTION = "Description";
        static const std::string FEATURE = "Feature";
        static const std::string MAINTAINER = "Maintainer";
        static const std::string SOURCE = "Source";
        static const std::string VERSION = "Version";
        static const std::string HOMEPAGE = "Homepage";
        static const std::string TYPE = "Type";
        static const std::string SUPPORTS = "Supports";
    }

    static Span<const std::string> get_list_of_valid_fields()
    {
        static const std::string valid_fields[] = {
            SourceParagraphFields::SOURCE,
            SourceParagraphFields::VERSION,
            SourceParagraphFields::DESCRIPTION,
            SourceParagraphFields::MAINTAINER,
            SourceParagraphFields::BUILD_DEPENDS,
            SourceParagraphFields::HOMEPAGE,
            SourceParagraphFields::TYPE,
            SourceParagraphFields::SUPPORTS,
        };

        return valid_fields;
    }

    void print_error_message(Span<const std::unique_ptr<Parse::ParseControlErrorInfo>> error_info_list)
    {
        Checks::check_exit(VCPKG_LINE_INFO, error_info_list.size() > 0);

        for (auto&& error_info : error_info_list)
        {
            Checks::check_exit(VCPKG_LINE_INFO, error_info != nullptr);
            if (!error_info->error.empty())
            {
                System::print2(
                    System::Color::error, "Error: while loading ", error_info->name, ":\n", error_info->error, '\n');
            }
        }

        bool have_remaining_fields = false;
        for (auto&& error_info : error_info_list)
        {
            if (!error_info->extra_fields.empty())
            {
                System::print2(System::Color::error,
                               "Error: There are invalid fields in the control file of ",
                               error_info->name,
                               '\n');
                System::print2("The following fields were not expected:\n\n    ",
                               Strings::join("\n    ", error_info->extra_fields),
                               "\n\n");
                have_remaining_fields = true;
            }
        }

        if (have_remaining_fields)
        {
            System::print2("This is the list of valid fields (case-sensitive): \n\n    ",
                           Strings::join("\n    ", get_list_of_valid_fields()),
                           "\n\n");
            System::print2("Different source may be available for vcpkg. Use .\\bootstrap-vcpkg.bat to update.\n\n");
        }

        for (auto&& error_info : error_info_list)
        {
            if (!error_info->missing_fields.empty())
            {
                System::print2(System::Color::error,
                               "Error: There are missing fields in the control file of ",
                               error_info->name,
                               '\n');
                System::print2("The following fields were missing:\n\n    ",
                               Strings::join("\n    ", error_info->missing_fields),
                               "\n\n");
            }
        }
    }

    std::string Type::to_string(const Type& t)
    {
        switch (t.type)
        {
            case Type::ALIAS: return "Alias";
            case Type::PORT: return "Port";
            default: return "Unknown";
        }
    }

    Type Type::from_string(const std::string& t)
    {
        if (t == "Alias") return Type{Type::ALIAS};
        if (t == "Port" || t == "") return Type{Type::PORT};
        return Type{Type::UNKNOWN};
    }

    static ParseExpected<SourceParagraph> parse_source_paragraph(const fs::path& path_to_control, RawParagraph&& fields)
    {
        ParagraphParser parser(std::move(fields));

        auto spgh = std::make_unique<SourceParagraph>();

        parser.required_field(SourceParagraphFields::SOURCE, spgh->name);
        parser.required_field(SourceParagraphFields::VERSION, spgh->version);

        spgh->description = parser.optional_field(SourceParagraphFields::DESCRIPTION);
        spgh->maintainer = parser.optional_field(SourceParagraphFields::MAINTAINER);
        spgh->homepage = parser.optional_field(SourceParagraphFields::HOMEPAGE);
        spgh->depends = parse_dependencies_list(parser.optional_field(SourceParagraphFields::BUILD_DEPENDS))
                            .value_or_exit(VCPKG_LINE_INFO);
        spgh->default_features =
            parse_default_features_list(parser.optional_field(SourceParagraphFields::DEFAULTFEATURES))
                .value_or_exit(VCPKG_LINE_INFO);
        spgh->supports_expression = parser.optional_field(SourceParagraphFields::SUPPORTS);
        spgh->type = Type::from_string(parser.optional_field(SourceParagraphFields::TYPE));
        auto err = parser.error_info(spgh->name.empty() ? path_to_control.u8string() : spgh->name);
        if (err)
            return err;
        else
            return spgh;
    }

    static ParseExpected<FeatureParagraph> parse_feature_paragraph(const fs::path& path_to_control,
                                                                   RawParagraph&& fields)
    {
        ParagraphParser parser(std::move(fields));

        auto fpgh = std::make_unique<FeatureParagraph>();

        parser.required_field(SourceParagraphFields::FEATURE, fpgh->name);
        parser.required_field(SourceParagraphFields::DESCRIPTION, fpgh->description);

        fpgh->depends = parse_dependencies_list(parser.optional_field(SourceParagraphFields::BUILD_DEPENDS))
                            .value_or_exit(VCPKG_LINE_INFO);

        auto err = parser.error_info(fpgh->name.empty() ? path_to_control.u8string() : fpgh->name);
        if (err)
            return err;
        else
            return fpgh;
    }

    ParseExpected<SourceControlFile> SourceControlFile::parse_control_file(
        const fs::path& path_to_control, std::vector<Parse::RawParagraph>&& control_paragraphs)
    {
        if (control_paragraphs.size() == 0)
        {
            auto ret = std::make_unique<Parse::ParseControlErrorInfo>();
            ret->name = path_to_control.u8string();
            return ret;
        }

        auto control_file = std::make_unique<SourceControlFile>();

        auto maybe_source = parse_source_paragraph(path_to_control, std::move(control_paragraphs.front()));
        if (const auto source = maybe_source.get())
            control_file->core_paragraph = std::move(*source);
        else
            return std::move(maybe_source).error();

        control_paragraphs.erase(control_paragraphs.begin());

        for (auto&& feature_pgh : control_paragraphs)
        {
            auto maybe_feature = parse_feature_paragraph(path_to_control, std::move(feature_pgh));
            if (const auto feature = maybe_feature.get())
                control_file->feature_paragraphs.emplace_back(std::move(*feature));
            else
                return std::move(maybe_feature).error();
        }

        return control_file;
    }

    Optional<const FeatureParagraph&> SourceControlFile::find_feature(const std::string& featurename) const
    {
        auto it = Util::find_if(feature_paragraphs,
                                [&](const std::unique_ptr<FeatureParagraph>& p) { return p->name == featurename; });
        if (it != feature_paragraphs.end())
            return **it;
        else
            return nullopt;
    }
    Optional<const std::vector<Dependency>&> SourceControlFile::find_dependencies_for_feature(
        const std::string& featurename) const
    {
        if (featurename == "core")
        {
            return core_paragraph->depends;
        }
        else if (auto p_feature = find_feature(featurename).get())
            return p_feature->depends;
        else
            return nullopt;
    }

    std::vector<FullPackageSpec> filter_dependencies(const std::vector<vcpkg::Dependency>& deps,
                                                     Triplet t,
                                                     const std::unordered_map<std::string, std::string>& cmake_vars)
    {
        std::vector<FullPackageSpec> ret;
        for (auto&& dep : deps)
        {
            const auto& qualifier = dep.qualifier;
            if (qualifier.empty() ||
                evaluate_expression(qualifier, {cmake_vars, t.canonical_name()}).value_or_exit(VCPKG_LINE_INFO))
            {
                ret.emplace_back(FullPackageSpec({dep.depend.name, t}, dep.depend.features));
            }
        }
        return ret;
    }
}
