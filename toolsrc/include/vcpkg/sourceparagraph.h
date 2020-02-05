#pragma once

#include <vcpkg/packagespec.h>
#include <vcpkg/parse.h>

#include <vcpkg/base/expected.h>
#include <vcpkg/base/span.h>
#include <vcpkg/base/system.h>

#include <vcpkg/base/system.print.h>

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

    std::vector<FullPackageSpec> filter_dependencies(const std::vector<Dependency>& deps,
                                                     const Triplet& t,
                                                     const std::unordered_map<std::string, std::string>& cmake_vars);

    // zlib[uwp] becomes Dependency{"zlib", "uwp"}
    std::vector<Dependency> expand_qualified_dependencies(const std::vector<std::string>& depends);

    std::string to_string(const Dependency& dep);

    struct Type
    {
        enum
        {
            UNKNOWN,
            PORT,
            ALIAS,
        } type;

        static std::string to_string(const Type&);
        static Type from_string(const std::string&);
    };

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
        std::vector<Dependency> depends;
        std::vector<std::string> default_features;
        Type type;
        std::string supports_expression;
    };

    /// <summary>
    /// Full metadata of a package: core and other features.
    /// </summary>
    struct SourceControlFile
    {
        SourceControlFile() = default;
        SourceControlFile(const SourceControlFile& scf)
            : core_paragraph(std::make_unique<SourceParagraph>(*scf.core_paragraph))
        {
            for (const auto& feat_ptr : scf.feature_paragraphs)
            {
                feature_paragraphs.emplace_back(std::make_unique<FeatureParagraph>(*feat_ptr));
            }
        }

        static Parse::ParseExpected<SourceControlFile> parse_control_file(
            const fs::path& path_to_control, std::vector<Parse::RawParagraph>&& control_paragraphs);

        std::unique_ptr<SourceParagraph> core_paragraph;
        std::vector<std::unique_ptr<FeatureParagraph>> feature_paragraphs;

        Optional<const FeatureParagraph&> find_feature(const std::string& featurename) const;
        Optional<const std::vector<Dependency>&> find_dependencies_for_feature(const std::string& featurename) const;
    };

    /// <summary>
    /// Full metadata of a package: core and other features. As well as the location the SourceControlFile was
    /// loaded from.
    /// </summary>
    struct SourceControlFileLocation
    {
        SourceControlFileLocation(const SourceControlFileLocation& scfl)
            : source_control_file(std::make_unique<SourceControlFile>(*scfl.source_control_file))
            , source_location(scfl.source_location)
        {
        }

        SourceControlFileLocation(std::unique_ptr<SourceControlFile>&& scf, fs::path&& source)
            : source_control_file(std::move(scf)), source_location(std::move(source))
        {
        }

        SourceControlFileLocation(std::unique_ptr<SourceControlFile>&& scf, const fs::path& source)
            : source_control_file(std::move(scf)), source_location(source)
        {
        }

        std::unique_ptr<SourceControlFile> source_control_file;
        fs::path source_location;
    };

    void print_error_message(Span<const std::unique_ptr<Parse::ParseControlErrorInfo>> error_info_list);
    inline void print_error_message(const std::unique_ptr<Parse::ParseControlErrorInfo>& error_info_list)
    {
        return print_error_message({&error_info_list, 1});
    }
}
