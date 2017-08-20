#pragma once

#include "PackageSpecParseResult.h"
#include "Triplet.h"
#include "vcpkg_expected.h"

namespace vcpkg
{
    struct ParsedSpecifier
    {
        std::string name;
        std::vector<std::string> features;
        std::string triplet;

        static ExpectedT<ParsedSpecifier, PackageSpecParseResult> from_string(const std::string& input);
    };

    struct PackageSpec
    {
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

    struct Features
    {
        std::string name;
        std::vector<std::string> features;

        static ExpectedT<Features, PackageSpecParseResult> from_string(const std::string& input);
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
