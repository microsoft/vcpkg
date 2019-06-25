#pragma once

#include <vcpkg/packagespec.h>
#include <vcpkg/parse.h>

#include <vcpkg/base/expected.h>
#include <vcpkg/base/span.h>
#include <vcpkg/base/system.h>

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

    /// <summary>
    /// Port metadata of additional feature in a package (part of CONTROL file)
    /// </summary>
    struct FeatureParagraph
    {
        std::string name;
        std::string description;
        std::vector<Dependency> depends;
    };

    /// <summary>
    /// Port metadata of the core feature of a package (part of CONTROL file)
    /// </summary>
    struct SourceParagraph
    {
        std::string name;
        std::string version;
        std::string description;
        std::string maintainer;
        std::string homepage;
        std::vector<std::string> supports;
        std::vector<Dependency> depends;
        std::vector<std::string> default_features;
    };

    /// <summary>
    /// Full metadata of a package: core and other features.
    /// </summary>
    struct SourceControlFile
    {
        static Parse::ParseExpected<SourceControlFile> parse_control_file(
            std::vector<Parse::RawParagraph>&& control_paragraphs);

        std::unique_ptr<SourceParagraph> core_paragraph;
        std::vector<std::unique_ptr<FeatureParagraph>> feature_paragraphs;

        Optional<const FeatureParagraph&> find_feature(const std::string& featurename) const;
    };

    /// <summary>
    /// Full metadata of a package: core and other features. As well as the location the SourceControlFile was loaded from.
    /// </summary>
    struct SourceControlFileLocation
    {
        std::unique_ptr<SourceControlFile> source_control_file;
        fs::path source_location;
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
