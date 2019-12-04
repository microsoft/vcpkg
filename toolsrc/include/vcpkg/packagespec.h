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

    ///
    /// <summary>
    /// Full specification of a package. Contains all information to reference
    /// a specific package.
    /// </summary>
    ///
    struct PackageSpec
    {
        static ExpectedT<PackageSpec, PackageSpecParseResult> from_name_and_triplet(const std::string& name,
                                                                                    const Triplet& triplet);

        static std::vector<PackageSpec> to_package_specs(const std::vector<std::string>& ports, const Triplet& triplet);

        const std::string& name() const;

        const Triplet& triplet() const;

        std::string dir() const;

        std::string to_string() const;
        void to_string(std::string& s) const;

        bool operator<(const PackageSpec& other) const
        {
            if (name() < other.name()) return true;
            if (name() > other.name()) return false;
            return triplet() < other.triplet();
        }

    private:
        std::string m_name;
        Triplet m_triplet;
    };

    ///
    /// <summary>
    /// Full specification of a feature. Contains all information to reference
    /// a single feature in a specific package.
    /// </summary>
    ///
    struct FeatureSpec
    {
        FeatureSpec(const PackageSpec& spec, const std::string& feature) : m_spec(spec), m_feature(feature) {}

        const std::string& name() const { return m_spec.name(); }
        const std::string& feature() const { return m_feature; }
        const Triplet& triplet() const { return m_spec.triplet(); }

        const PackageSpec& spec() const { return m_spec; }

        std::string to_string() const;
        void to_string(std::string& out) const;

        static std::vector<FeatureSpec> from_strings_and_triplet(const std::vector<std::string>& depends,
                                                                 const Triplet& t);

        bool operator<(const FeatureSpec& other) const
        {
            if (name() < other.name()) return true;
            if (name() > other.name()) return false;
            if (feature() < other.feature()) return true;
            if (feature() > other.feature()) return false;
            return triplet() < other.triplet();
        }

        bool operator==(const FeatureSpec& other) const
        {
            return triplet() == other.triplet() && name() == other.name() && feature() == other.feature();
        }

        bool operator!=(const FeatureSpec& other) const { return !(*this == other); }

    private:
        PackageSpec m_spec;
        std::string m_feature;
    };

    ///
    /// <summary>
    /// Full specification of a package. Contains all information to reference
    /// a collection of features in a single package.
    /// </summary>
    ///
    struct FullPackageSpec
    {
        PackageSpec package_spec;
        std::vector<std::string> features;

        static std::vector<FeatureSpec> to_feature_specs(const std::vector<FullPackageSpec>& specs);

        static std::vector<FeatureSpec> to_feature_specs(const FullPackageSpec& spec,
                                                         const std::vector<std::string>& default_features, 
                                                         const std::vector<std::string>& all_features);

        static ExpectedT<FullPackageSpec, PackageSpecParseResult> from_string(const std::string& spec_as_string,
                                                                              const Triplet& default_triplet);
    };

    ///
    /// <summary>
    /// Contains all information to reference a collection of features in a single package by their names.
    /// </summary>
    ///
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

    template<>
    struct hash<vcpkg::FeatureSpec>
    {
        size_t operator()(const vcpkg::FeatureSpec& value) const
        {
            size_t hash = std::hash<vcpkg::PackageSpec>()(value.spec());
            hash = hash * 31 + std::hash<std::string>()(value.feature());
            return hash;
        }
    };

    template<>
    struct equal_to<vcpkg::FeatureSpec>
    {
        bool operator()(const vcpkg::FeatureSpec& left, const vcpkg::FeatureSpec& right) const { return left == right; }
    };
}
