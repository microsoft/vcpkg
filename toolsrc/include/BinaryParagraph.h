#pragma once

#include <unordered_map>
#include "SourceParagraph.h"
#include "PackageSpec.h"

namespace vcpkg
{
    struct BinaryParagraph
    {
        BinaryParagraph();
        explicit BinaryParagraph(std::unordered_map<std::string, std::string> fields);
        BinaryParagraph(const SourceParagraph& spgh, const Triplet& target_triplet);

        std::string displayname() const;

        std::string fullstem() const;

        std::string dir() const;

        PackageSpec spec;
        std::string version;
        std::string description;
        std::string maintainer;
        std::vector<std::string> depends;
    };

    std::ostream& operator<<(std::ostream& os, const BinaryParagraph& pgh);
}
