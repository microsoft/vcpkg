#pragma once

#include <vcpkg/base/expected.h>
#include <vcpkg/packagespecparseresult.h>
#include <vcpkg/triplet.h>

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

    struct FeatureSpec
    {
        FeatureSpec(const PackageSpec& spec, const std::string& feature) : m_spec(spec), m_feature(feature) {}

        const std::string& name() const { return m_spec.name(); }
        const std::string& feature() const { return m_feature; }
        const Triplet& triplet() const { return m_spec.triplet(); }

        const PackageSpec& spec() const { return m_spec; }

        std::string to_string() const;

        static std::vector<FeatureSpec> from_strings_and_triplet(const std::vector<std::string>& depends,
                                                                 const Triplet& t);

    private:
        PackageSpec m_spec;
        std::string m_feature;
    };

    struct FullPackageSpec
    {
        PackageSpec package_spec;
        std::vector<std::string> features;

        static std::vector<FeatureSpec> to_feature_specs(const std::vector<FullPackageSpec>& specs);

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

namespace std
{
    template<>
    struct hash<vcpkg::PackageSpec>
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
    struct equal_to<vcpkg::PackageSpec>
    {
        bool operator()(const vcpkg::PackageSpec& left, const vcpkg::PackageSpec& right) const { return left == right; }
    };
}
