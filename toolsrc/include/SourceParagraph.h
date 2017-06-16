#pragma once

#include "Span.h"
#include "vcpkg_System.h"
#include "vcpkg_expected.h"

#include <string>
#include <unordered_map>
#include <vector>

namespace vcpkg
{
    extern bool g_feature_packages;

    struct Triplet;

    struct Dependency
    {
        std::string name;
        std::string qualifier;
    };

    const std::string& to_string(const Dependency& dep);

    struct ParseControlErrorInfo
    {
        std::string name;
        std::string remaining_fields_as_string;
        std::error_code error;
    };

    struct FeatureParagraph
    {
        std::string name;
        std::string description;
        std::vector<Dependency> depends;
    };

    /// <summary>
    /// Port metadata (CONTROL file)
    /// </summary>
    struct SourceParagraph
    {
        std::string name;
        std::string version;
        std::string description;
        std::string maintainer;
        std::vector<std::string> supports;
        std::vector<Dependency> depends;
        std::string default_features;
    };
    struct SourceControlFile
    {
        static ExpectedT<SourceControlFile, ParseControlErrorInfo> parse_control_file(
            std::vector<std::unordered_map<std::string, std::string>>&& control_paragraphs);

        SourceParagraph core_paragraph;
        std::vector<std::unique_ptr<FeatureParagraph>> feature_paragraphs;

        std::vector<ParseControlErrorInfo> errors;
    };

    std::vector<SourceParagraph> getSourceParagraphs(const std::vector<SourceControlFile>& control_files);

    void print_error_message(span<const ParseControlErrorInfo> error_info_list);
    inline void print_error_message(const ParseControlErrorInfo& error_info_list)
    {
        return print_error_message({&error_info_list, 1});
    }

    std::vector<std::string> filter_dependencies(const std::vector<Dependency>& deps, const Triplet& t);

    std::vector<Dependency> expand_qualified_dependencies(const std::vector<std::string>& depends);
    std::vector<std::string> parse_comma_list(const std::string& str);

    struct Supports
    {
        static ExpectedT<Supports, std::vector<std::string>> parse(const std::vector<std::string>& strs);

        using Architecture = System::CPUArchitecture;

        enum class Platform
        {
            WINDOWS,
            UWP,
        };
        enum class Linkage
        {
            DYNAMIC,
            STATIC,
        };
        enum class ToolsetVersion
        {
            V140,
            V141,
        };

        bool is_supported(Architecture arch, Platform plat, Linkage crt, ToolsetVersion tools);

    private:
        std::vector<Architecture> architectures;
        std::vector<Platform> platforms;
        std::vector<Linkage> crt_linkages;
        std::vector<ToolsetVersion> toolsets;
    };
}
