#pragma once

#include <vcpkg/base/fwd/json.h>

#include <vcpkg/base/expected.h>
#include <vcpkg/base/span.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/system.print.h>

#include <vcpkg/packagespec.h>
#include <vcpkg/paragraphparser.h>
#include <vcpkg/platform-expression.h>

namespace vcpkg
{
    std::vector<FullPackageSpec> filter_dependencies(const std::vector<Dependency>& deps,
                                                     Triplet t,
                                                     const std::unordered_map<std::string, std::string>& cmake_vars);

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

    bool operator==(const Type&, const Type&);
    bool operator!=(const Type&, const Type&);

    /// <summary>
    /// Port metadata of additional feature in a package (part of CONTROL file)
    /// </summary>
    struct FeatureParagraph
    {
        std::string name;
        std::vector<std::string> description;
        std::vector<Dependency> dependencies;

        Json::Object extra_info;

        friend bool operator==(const FeatureParagraph& lhs, const FeatureParagraph& rhs);
        friend bool operator!=(const FeatureParagraph& lhs, const FeatureParagraph& rhs) { return !(lhs == rhs); }
    };

    /// <summary>
    /// Port metadata of the core feature of a package (part of CONTROL file)
    /// </summary>
    struct SourceParagraph
    {
        std::string name;
        std::string version;
        int port_version = 0;
        std::vector<std::string> description;
        std::vector<std::string> maintainers;
        std::string homepage;
        std::string documentation;
        std::vector<Dependency> dependencies;
        std::vector<std::string> default_features;
        std::string license; // SPDX license expression

        Type type;
        PlatformExpression::Expr supports_expression;

        Json::Object extra_info;

        friend bool operator==(const SourceParagraph& lhs, const SourceParagraph& rhs);
        friend bool operator!=(const SourceParagraph& lhs, const SourceParagraph& rhs) { return !(lhs == rhs); }
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
                feature_paragraphs.push_back(std::make_unique<FeatureParagraph>(*feat_ptr));
            }
        }

        static Parse::ParseExpected<SourceControlFile> parse_manifest_file(const fs::path& path_to_manifest,
                                                                           const Json::Object& object);

        static Parse::ParseExpected<SourceControlFile> parse_control_file(
            const fs::path& path_to_control, std::vector<Parse::Paragraph>&& control_paragraphs);

        // Always non-null in non-error cases
        std::unique_ptr<SourceParagraph> core_paragraph;
        std::vector<std::unique_ptr<FeatureParagraph>> feature_paragraphs;

        Optional<const FeatureParagraph&> find_feature(const std::string& featurename) const;
        Optional<const std::vector<Dependency>&> find_dependencies_for_feature(const std::string& featurename) const;

        friend bool operator==(const SourceControlFile& lhs, const SourceControlFile& rhs);
        friend bool operator!=(const SourceControlFile& lhs, const SourceControlFile& rhs) { return !(lhs == rhs); }
    };

    Json::Object serialize_manifest(const SourceControlFile& scf);
    Json::Object serialize_debug_manifest(const SourceControlFile& scf);

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
