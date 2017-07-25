#pragma once
#include "PackageSpecParseResult.h"
#include "SourceParagraph.h"
#include "Triplet.h"
#include "vcpkg_expected.h"

namespace vcpkg
{
    struct PackageSpec
    {
        static std::string to_string(const std::string& name, const Triplet& triplet);
        static ExpectedT<PackageSpec, PackageSpecParseResult> from_name_and_triplet(const std::string& name,
                                                                                    const Triplet& triplet);

        const std::string& name() const;

        const Triplet& triplet() const;

        std::string dir() const;

        std::string to_string() const;

    private:
        std::string m_name;
        Triplet m_triplet;
    };

    struct FullPackageSpec
    {
        PackageSpec package_spec;
        std::vector<std::string> features;

        static ExpectedT<FullPackageSpec, PackageSpecParseResult> from_string(const std::string& spec_as_string,
                                                                              const Triplet& default_triplet);
    };

    bool operator==(const PackageSpec& left, const PackageSpec& right);
    bool operator!=(const PackageSpec& left, const PackageSpec& right);
}

template<>
struct std::hash<vcpkg::PackageSpec>
{
    size_t operator()(const vcpkg::PackageSpec& value) const
    {
        size_t hash = 17;
        hash = hash * 31 + std::hash<std::string>()(value.name());
        hash = hash * 31 + std::hash<vcpkg::Triplet>()(value.triplet());
        return hash;
    }
};

template<>
struct std::equal_to<vcpkg::PackageSpec>
{
    bool operator()(const vcpkg::PackageSpec& left, const vcpkg::PackageSpec& right) const { return left == right; }
};
