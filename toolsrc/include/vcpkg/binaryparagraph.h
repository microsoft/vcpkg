#pragma once

#include <vcpkg/packagespec.h>
#include <vcpkg/paragraphparser.h>
#include <vcpkg/sourceparagraph.h>

namespace vcpkg
{
    /// <summary>
    /// Built package metadata
    /// </summary>
    struct BinaryParagraph
    {
        BinaryParagraph();
        explicit BinaryParagraph(Parse::Paragraph fields);
        BinaryParagraph(const SourceParagraph& spgh,
                        Triplet triplet,
                        const std::string& abi_tag,
                        const std::vector<FeatureSpec>& deps);
        BinaryParagraph(const SourceParagraph& spgh,
                        const FeatureParagraph& fpgh,
                        Triplet triplet,
                        const std::vector<FeatureSpec>& deps);

        std::string displayname() const;

        std::string fullstem() const;

        std::string dir() const;

        PackageSpec spec;
        std::string version;
        std::string description;
        std::string maintainer;
        std::string feature;
        std::vector<std::string> default_features;
        std::vector<std::string> depends;
        std::string abi;
        Type type;
    };

    struct BinaryControlFile
    {
        BinaryParagraph core_paragraph;
        std::vector<BinaryParagraph> features;
    };

    void serialize(const BinaryParagraph& pgh, std::string& out_str);
}
