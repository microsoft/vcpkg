#pragma once

#include <unordered_map>
#include "SourceParagraph.h"
#include "triplet.h"

namespace vcpkg
{
    struct BinaryParagraph
    {
        BinaryParagraph();
        explicit BinaryParagraph(const std::unordered_map<std::string, std::string>& fields);
        BinaryParagraph(const SourceParagraph& spgh, const triplet& target_triplet);

        std::string displayname() const;

        std::string fullstem() const;

        std::string dir() const;

        std::string name;
        std::string version;
        std::string description;
        std::string maintainer;
        triplet target_triplet;
        std::vector<std::string> depends;
    };

    std::ostream& operator<<(std::ostream& os, const BinaryParagraph& pgh);
}
