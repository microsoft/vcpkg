#include "pch.h"

#include "SourceParagraph.h"
#include "Triplet.h"
#include "vcpkg_Checks.h"
#include "vcpkg_Maps.h"
#include "vcpkg_System.h"
#include "vcpkg_Util.h"
#include "vcpkg_expected.h"

#include "vcpkglib_helpers.h"

namespace vcpkg
{
    // feature package feature is default to off
    bool feature_packages = false;

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
        static const std::string SUPPORTS = "Supports";
        static const std::string DEFAULTFEATURES = "Default-Features";
    }

    static span<const std::string> get_list_of_valid_fields()
    {
        static const std::string valid_fields[] = {SourceParagraphRequiredField::SOURCE,
                                                   SourceParagraphRequiredField::VERSION,

                                                   SourceParagraphOptionalField::DESCRIPTION,
                                                   SourceParagraphOptionalField::MAINTAINER,
                                                   SourceParagraphOptionalField::BUILD_DEPENDS,
                                                   SourceParagraphOptionalField::SUPPORTS};

        return valid_fields;
    }

    void print_error_message(span<const ParseControlErrorInfo> error_info_list)
    {
        Checks::check_exit(VCPKG_LINE_INFO, error_info_list.size() > 0);

        for (auto&& error_info : error_info_list)
        {
            if (error_info.error)
            {
                System::println(
                    System::Color::error, "Error: while loading %s: %s", error_info.name, error_info.error.message());
            }
        }

        bool have_remaining_fields = false;
        for (auto&& error_info : error_info_list)
        {
            if (!error_info.remaining_fields_as_string.empty())
            {
                System::println(System::Color::error,
                                "Error: There are invalid fields in the Source Paragraph of %s",
                                error_info.name);
                System::println("The following fields were not expected:\n\n    %s\n\n",
                                error_info.remaining_fields_as_string);
                have_remaining_fields = true;
            }
        }

        if (have_remaining_fields)
        {
            System::println("This is the list of valid fields (case-sensitive): \n\n    %s\n",
                            Strings::join("\n    ", get_list_of_valid_fields()));
            System::println("Different source may be available for vcpkg. Use .\\bootstrap-vcpkg.bat to update.\n");
        }
    }
    std::vector<SourceParagraph> getSourceParagraphs(const std::vector<SourceControlFile>& control_files)
    {
        return Util::fmap(control_files, [](const SourceControlFile& x) { return x.core_paragraph; });
    }

    ExpectedT<SourceControlFile, ParseControlErrorInfo> SourceControlFile::parse_control_file(
        std::vector<std::unordered_map<std::string, std::string>>&& control_paragraphs)
    {
        // nonzero
        // Checks::check_exit(VCPKG_LINE_INFO, !control_paragraphs.empty()); // return ExpectedT instead
        std::unordered_map<std::string, std::string> fields = control_paragraphs.front();

        SourceControlFile control_file;
        SourceParagraph& sparagraph = control_file.core_paragraph;
        sparagraph.name = details::remove_required_field(&fields, SourceParagraphRequiredField::SOURCE);
        sparagraph.version = details::remove_required_field(&fields, SourceParagraphRequiredField::VERSION);
        sparagraph.description = details::remove_optional_field(&fields, SourceParagraphOptionalField::DESCRIPTION);
        sparagraph.maintainer = details::remove_optional_field(&fields, SourceParagraphOptionalField::MAINTAINER);

        std::string deps = details::remove_optional_field(&fields, SourceParagraphOptionalField::BUILD_DEPENDS);
        sparagraph.depends = expand_qualified_dependencies(parse_comma_list(deps));

        std::string sups = details::remove_optional_field(&fields, SourceParagraphOptionalField::SUPPORTS);
        sparagraph.supports = parse_comma_list(sups);

        control_paragraphs.erase(control_paragraphs.begin());

        if (feature_packages)
        {
            for (auto&& feature_pgh : control_paragraphs)
            {
                // unique ptr cannot be copied, so this calls the move constructor, or is this an initialization
                // std::unique_ptr<FeatureParagraph> fparagraph = std::make_unique<FeatureParagraph>();

                sparagraph.default_features =
                    details::remove_optional_field(&fields, SourceParagraphOptionalField::DEFAULTFEATURES);

                control_file.feature_paragraphs.emplace_back(std::make_unique<FeatureParagraph>());

                FeatureParagraph& fparagraph = *control_file.feature_paragraphs.back();

                fparagraph.name = details::remove_required_field(&feature_pgh, FeatureParagraphRequiredField::FEATURE);
                fparagraph.description =
                    details::remove_required_field(&feature_pgh, FeatureParagraphOptionalField::DESCRIPTION);
                std::string feature_deps =
                    details::remove_optional_field(&feature_pgh, FeatureParagraphOptionalField::BUILD_DEPENDS);
                fparagraph.depends = expand_qualified_dependencies(parse_comma_list(feature_deps));

                // why do we need a std move here
                // control_file.feature_paragraphs.emplace_back(std::move(fparagraph));
            }
        }

        if (!fields.empty())
        {
            const std::vector<std::string> remaining_fields = Maps::extract_keys(fields);

            const std::string remaining_fields_as_string = Strings::join("\n    ", remaining_fields);

            return ParseControlErrorInfo{sparagraph.name, remaining_fields_as_string};
        }
        return control_file;
    }

    std::vector<Dependency> vcpkg::expand_qualified_dependencies(const std::vector<std::string>& depends)
    {
        return Util::fmap(depends, [&](const std::string& depend_string) -> Dependency {
            auto pos = depend_string.find(' ');
            if (pos == std::string::npos) return {depend_string, ""};
            // expect of the form "\w+ \[\w+\]"
            Dependency dep;
            dep.name = depend_string.substr(0, pos);
            if (depend_string.c_str()[pos + 1] != '[' || depend_string[depend_string.size() - 1] != ']')
            {
                // Error, but for now just slurp the entire string.
                return {depend_string, ""};
            }
            dep.qualifier = depend_string.substr(pos + 2, depend_string.size() - pos - 3);
            return dep;
        });
    }

    std::vector<std::string> parse_comma_list(const std::string& str)
    {
        if (str.empty())
        {
            return {};
        }

        std::vector<std::string> out;

        size_t cur = 0;
        do
        {
            auto pos = str.find(',', cur);
            if (pos == std::string::npos)
            {
                out.push_back(str.substr(cur));
                break;
            }
            out.push_back(str.substr(cur, pos - cur));

            // skip comma and space
            ++pos;
            if (str[pos] == ' ')
            {
                ++pos;
            }

            cur = pos;
        } while (cur != std::string::npos);

        return out;
    }

    std::vector<std::string> filter_dependencies(const std::vector<vcpkg::Dependency>& deps, const Triplet& t)
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

    const std::string& to_string(const Dependency& dep) { return dep.name; }

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
        auto is_in_or_empty = [](auto v, auto&& c) -> bool { return c.empty() || c.end() != Util::find(c, v); };
        if (!is_in_or_empty(arch, architectures)) return false;
        if (!is_in_or_empty(plat, platforms)) return false;
        if (!is_in_or_empty(crt, crt_linkages)) return false;
        if (!is_in_or_empty(tools, toolsets)) return false;
        return true;
    }
}
