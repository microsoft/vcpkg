#pragma once

#include "SourceParagraph.h"
#include "vcpkg_expected.h"
#include <memory>
#include <unordered_map>

namespace vcpkg
{
    struct Triplet;

    // const std::string& to_string(const Dependency& dep);

    /// <summary>
    /// Features in the CONTROL file
    /// </summary>
    struct FeatureParagraph
    {
        // static ExpectedT<SourceParagraph, ParseControlErrorInfo> parse_control_file(
        //    std::unordered_map<std::string, std::string> fields);

        FeatureParagraph() = default;

        std::string name;
        std::string description;
        std::vector<Dependency> depends;
    };

    struct ParseFeatureErrorInfo
    {
    };

    struct SourceControlFile
    {
        SourceParagraph core_paragraph;
        std::vector<std::unique_ptr<FeatureParagraph>> feature_paragraphs;
    };
    std::vector<SourceParagraph> getSourceParagraphs(const std::vector<SourceControlFile>& control_files);

    namespace FeatureParagraphRequiredField
    {
        static const std::string FEATURE = "Feature";
    }

    namespace FeatureParagraphOptionalField
    {
        static const std::string DESCRIPTION = "Description";
        static const std::string BUILD_DEPENDS = "Build-Depends";
    }

    // std::vector<std::string> filter_dependencies(const std::vector<Dependency>& deps, const Triplet& t);
    // std::vector<Dependency> expand_qualified_dependencies(const std::vector<std::string>& depends);
    // std::vector<std::string> parse_depends(const std::string& depends_string);
}
