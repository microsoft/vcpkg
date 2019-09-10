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
        static const std::string SUPPORTS = "Supports";
        static const std::string VERSION = "Version";
        static const std::string HOMEPAGE = "Homepage";
        static const std::string TYPE = "Type";
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
        };

        return valid_fields;
    }

    void print_error_message(Span<const std::unique_ptr<Parse::ParseControlErrorInfo>> error_info_list)
    {
        Checks::check_exit(VCPKG_LINE_INFO, error_info_list.size() > 0);

        for (auto&& error_info : error_info_list)
        {
            Checks::check_exit(VCPKG_LINE_INFO, error_info != nullptr);
            if (error_info->error)
            {
                System::print2(System::Color::error,
                               "Error: while loading ",
                               error_info->name,
                               ": ",
                               error_info->error.message(),
                               '\n');
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

    static ParseExpected<SourceParagraph> parse_source_paragraph(RawParagraph&& fields)
    {
        ParagraphParser parser(std::move(fields));

        auto spgh = std::make_unique<SourceParagraph>();

        parser.required_field(SourceParagraphFields::SOURCE, spgh->name);
        parser.required_field(SourceParagraphFields::VERSION, spgh->version);

        spgh->description = parser.optional_field(SourceParagraphFields::DESCRIPTION);
        spgh->maintainer = parser.optional_field(SourceParagraphFields::MAINTAINER);
        spgh->homepage = parser.optional_field(SourceParagraphFields::HOMEPAGE);
        spgh->depends = expand_qualified_dependencies(
            parse_comma_list(parser.optional_field(SourceParagraphFields::BUILD_DEPENDS)));
        spgh->supports = parse_comma_list(parser.optional_field(SourceParagraphFields::SUPPORTS));
        spgh->default_features = parse_comma_list(parser.optional_field(SourceParagraphFields::DEFAULTFEATURES));

        auto err = parser.error_info(spgh->name);
        if (err)
            return std::move(err);
        else
            return std::move(spgh);
    }

    static ParseExpected<FeatureParagraph> parse_feature_paragraph(RawParagraph&& fields)
    {
        ParagraphParser parser(std::move(fields));

        auto fpgh = std::make_unique<FeatureParagraph>();

        parser.required_field(SourceParagraphFields::FEATURE, fpgh->name);
        parser.required_field(SourceParagraphFields::DESCRIPTION, fpgh->description);

        fpgh->depends = expand_qualified_dependencies(
            parse_comma_list(parser.optional_field(SourceParagraphFields::BUILD_DEPENDS)));

        auto err = parser.error_info(fpgh->name);
        if (err)
            return std::move(err);
        else
            return std::move(fpgh);
    }

    ParseExpected<SourceControlFile> SourceControlFile::parse_control_file(
        std::vector<Parse::RawParagraph>&& control_paragraphs)
    {
        if (control_paragraphs.size() == 0)
        {
            return std::make_unique<Parse::ParseControlErrorInfo>();
        }

        auto control_file = std::make_unique<SourceControlFile>();

        auto maybe_source = parse_source_paragraph(std::move(control_paragraphs.front()));
        if (const auto source = maybe_source.get())
            control_file->core_paragraph = std::move(*source);
        else
            return std::move(maybe_source).error();

        control_paragraphs.erase(control_paragraphs.begin());

        for (auto&& feature_pgh : control_paragraphs)
        {
            auto maybe_feature = parse_feature_paragraph(std::move(feature_pgh));
            if (const auto feature = maybe_feature.get())
                control_file->feature_paragraphs.emplace_back(std::move(*feature));
            else
                return std::move(maybe_feature).error();
        }

        return std::move(control_file);
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

    Dependency Dependency::parse_dependency(std::string name, std::string qualifier)
    {
        Dependency dep;
        dep.qualifier = qualifier;
        if (auto maybe_features = Features::from_string(name))
            dep.depend = *maybe_features.get();
        else
            Checks::exit_with_message(
                VCPKG_LINE_INFO, "error while parsing dependency: %s: %s", to_string(maybe_features.error()), name);
        return dep;
    }

    std::string Dependency::name() const
    {
        if (this->depend.features.empty()) return this->depend.name;

        const std::string features = Strings::join(",", this->depend.features);
        return Strings::format("%s[%s]", this->depend.name, features);
    }

    std::vector<Dependency> expand_qualified_dependencies(const std::vector<std::string>& depends)
    {
        return Util::fmap(depends, [&](const std::string& depend_string) -> Dependency {
            auto pos = depend_string.find(' ');
            if (pos == std::string::npos) return Dependency::parse_dependency(depend_string, "");
            // expect of the form "\w+ \[\w+\]"
            if (depend_string.c_str()[pos + 1] != '(' || depend_string[depend_string.size() - 1] != ')')
            {
                // Error, but for now just slurp the entire string.
                return Dependency::parse_dependency(depend_string, "");
            }
            return Dependency::parse_dependency(depend_string.substr(0, pos),
                                                depend_string.substr(pos + 2, depend_string.size() - pos - 3));
        });
    }

    std::vector<std::string> filter_dependencies(const std::vector<vcpkg::Dependency>& deps, const Triplet& t)
    {
        std::vector<std::string> ret;
        for (auto&& dep : deps)
        {
            const auto& qualifier = dep.qualifier;
            if (qualifier.empty() || evaluate_expression(qualifier, t.canonical_name()))
            {
                ret.emplace_back(dep.name());
            }
        }
        return ret;
    }

    std::vector<Features> filter_dependencies_to_features(const std::vector<vcpkg::Dependency>& deps, const Triplet& t)
    {
        std::vector<Features> ret;
        for (auto&& dep : deps)
        {
            const auto& qualifier = dep.qualifier;
            if (qualifier.empty() || evaluate_expression(qualifier, t.canonical_name()))
            {
                ret.emplace_back(dep.depend);
            }
        }
        return ret;
    }

    std::vector<FeatureSpec> filter_dependencies_to_specs(const std::vector<Dependency>& deps, const Triplet& t)
    {
        return FeatureSpec::from_strings_and_triplet(filter_dependencies(deps, t), t);
    }

    std::string to_string(const Dependency& dep) { return dep.name(); }

    ExpectedT<Supports, std::vector<std::string>> Supports::parse(const std::vector<std::string>& strs)
    {
        Supports ret;
        std::vector<std::string> unrecognized;

        for (auto&& str : strs)
        {
            if (str == "x64")
                ret.architectures.push_back(Architecture::X64);
            else if (str == "x86")
                ret.architectures.push_back(Architecture::X86);
            else if (str == "arm")
                ret.architectures.push_back(Architecture::ARM);
            else if (str == "windows")
                ret.platforms.push_back(Platform::WINDOWS);
            else if (str == "uwp")
                ret.platforms.push_back(Platform::UWP);
            else if (str == "v140")
                ret.toolsets.push_back(ToolsetVersion::V140);
            else if (str == "v141")
                ret.toolsets.push_back(ToolsetVersion::V141);
            else if (str == "crt-static")
                ret.crt_linkages.push_back(Linkage::STATIC);
            else if (str == "crt-dynamic")
                ret.crt_linkages.push_back(Linkage::DYNAMIC);
            else
                unrecognized.push_back(str);
        }

        if (unrecognized.empty())
            return std::move(ret);
        else
            return std::move(unrecognized);
    }

    bool Supports::is_supported(Architecture arch, Platform plat, Linkage crt, ToolsetVersion tools)
    {
        const auto is_in_or_empty = [](auto v, auto&& c) -> bool { return c.empty() || c.end() != Util::find(c, v); };
        if (!is_in_or_empty(arch, architectures)) return false;
        if (!is_in_or_empty(plat, platforms)) return false;
        if (!is_in_or_empty(crt, crt_linkages)) return false;
        if (!is_in_or_empty(tools, toolsets)) return false;
        return true;
    }
}
