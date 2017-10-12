#pragma once

#include "PackageSpec.h"
#include "Span.h"
#include "vcpkg_Parse.h"
#include "vcpkg_System.h"
#include "vcpkg_expected.h"

#include <string>
#include <vector>

namespace vcpkg
{
    struct Dependency
    {
        Features depend;
        std::string qualifier;

        std::string name() const;
        static Dependency parse_dependency(std::string name, std::string qualifier);
    };

    std::vector<std::string> filter_dependencies(const std::vector<Dependency>& deps, const Triplet& t);
    std::vector<FeatureSpec> filter_dependencies_to_specs(const std::vector<Dependency>& deps, const Triplet& t);

    // zlib[uwp] becomes Dependency{"zlib", "uwp"}
    std::vector<Dependency> expand_qualified_dependencies(const std::vector<std::string>& depends);

    std::string to_string(const Dependency& dep);

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
        std::vector<std::string> default_features;
    };
    struct SourceControlFile
    {
        static Parse::ParseExpected<SourceControlFile> parse_control_file(
            std::vector<Parse::RawParagraph>&& control_paragraphs);

        std::unique_ptr<SourceParagraph> core_paragraph;
        std::vector<std::unique_ptr<FeatureParagraph>> feature_paragraphs;
    };

    void print_error_message(Span<const std::unique_ptr<Parse::ParseControlErrorInfo>> error_info_list);
    inline void print_error_message(const std::unique_ptr<Parse::ParseControlErrorInfo>& error_info_list)
    {
        return print_error_message({&error_info_list, 1});
    }

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
