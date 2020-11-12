#pragma once

#include <vcpkg/base/expected.h>
#include <vcpkg/base/json.h>
#include <vcpkg/base/optional.h>

#include <vcpkg/platform-expression.h>
#include <vcpkg/triplet.h>
#include <vcpkg/versions.h>

namespace vcpkg::Parse
{
    struct ParserBase;
}

namespace vcpkg
{
    ///
    /// <summary>
    /// Full specification of a package. Contains all information to reference
    /// a specific package.
    /// </summary>
    ///
    struct PackageSpec
    {
        PackageSpec() = default;
        PackageSpec(std::string name, Triplet triplet) : m_name(std::move(name)), m_triplet(triplet) { }

        static std::vector<PackageSpec> to_package_specs(const std::vector<std::string>& ports, Triplet triplet);

        const std::string& name() const;

        Triplet triplet() const;

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

    bool operator==(const PackageSpec& left, const PackageSpec& right);
    inline bool operator!=(const PackageSpec& left, const PackageSpec& right) { return !(left == right); }

    ///
    /// <summary>
    /// Full specification of a feature. Contains all information to reference
    /// a single feature in a specific package.
    /// </summary>
    ///
    struct FeatureSpec
    {
        FeatureSpec(const PackageSpec& spec, const std::string& feature) : m_spec(spec), m_feature(feature) { }

        const std::string& name() const { return m_spec.name(); }
        const std::string& feature() const { return m_feature; }
        Triplet triplet() const { return m_spec.triplet(); }

        const PackageSpec& spec() const { return m_spec; }

        std::string to_string() const;
        void to_string(std::string& out) const;

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

        FullPackageSpec() = default;
        explicit FullPackageSpec(PackageSpec spec, std::vector<std::string> features = {})
            : package_spec(std::move(spec)), features(std::move(features))
        {
        }

        std::vector<FeatureSpec> to_feature_specs(const std::vector<std::string>& default_features,
                                                  const std::vector<std::string>& all_features) const;

        static ExpectedS<FullPackageSpec> from_string(const std::string& spec_as_string, Triplet default_triplet);

        bool operator==(const FullPackageSpec& o) const
        {
            return package_spec == o.package_spec && features == o.features;
        }
        bool operator!=(const FullPackageSpec& o) const { return !(*this == o); }
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

        static ExpectedS<Features> from_string(const std::string& input);
    };

    struct DependencyConstraint
    {
        Versions::Constraint::Type type = Versions::Constraint::Type::None;
        std::string value;
        int port_version = 0;

        friend bool operator==(const DependencyConstraint& lhs, const DependencyConstraint& rhs);
        friend bool operator!=(const DependencyConstraint& lhs, const DependencyConstraint& rhs)
        {
            return !(lhs == rhs);
        }
    };

    struct Dependency
    {
        std::string name;
        std::vector<std::string> features;
        PlatformExpression::Expr platform;
        DependencyConstraint constraint;

        Json::Object extra_info;

        friend bool operator==(const Dependency& lhs, const Dependency& rhs);
        friend bool operator!=(const Dependency& lhs, const Dependency& rhs) { return !(lhs == rhs); }
    };

    struct DependencyOverride
    {
        std::string name;
        std::string version;
        int port_version = 0;
        Versions::Scheme version_scheme = Versions::Scheme::String;

        Json::Object extra_info;

        friend bool operator==(const DependencyOverride& lhs, const DependencyOverride& rhs);
        friend bool operator!=(const DependencyOverride& lhs, const DependencyOverride& rhs) { return !(lhs == rhs); }
    };

    struct ParsedQualifiedSpecifier
    {
        std::string name;
        Optional<std::vector<std::string>> features;
        Optional<std::string> triplet;
        Optional<PlatformExpression::Expr> platform;
    };

    Optional<std::string> parse_feature_name(Parse::ParserBase& parser);
    Optional<std::string> parse_package_name(Parse::ParserBase& parser);
    ExpectedS<ParsedQualifiedSpecifier> parse_qualified_specifier(StringView input);
    Optional<ParsedQualifiedSpecifier> parse_qualified_specifier(Parse::ParserBase& parser);
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
