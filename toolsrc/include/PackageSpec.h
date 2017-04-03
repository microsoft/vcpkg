#pragma once
#include "package_spec_parse_result.h"
#include "triplet.h"
#include "vcpkg_expected.h"

namespace vcpkg
{
    struct PackageSpec
    {
        static expected<PackageSpec> from_string(const std::string& spec_as_string, const triplet& default_target_triplet);

        static expected<PackageSpec> from_name_and_triplet(const std::string& name, const triplet& target_triplet);

        const std::string& name() const;

        const triplet& target_triplet() const;

        std::string display_name() const;

        std::string dir() const;

        std::string toString() const;

    private:
        std::string m_name;
        triplet m_target_triplet;
    };

    std::string to_printf_arg(const PackageSpec& spec);

    bool operator==(const PackageSpec& left, const PackageSpec& right);

    std::ostream& operator<<(std::ostream& os, const PackageSpec& spec);
} //namespace vcpkg

namespace std
{
    template <>
    struct hash<vcpkg::PackageSpec>
    {
        size_t operator()(const vcpkg::PackageSpec& value) const
        {
            size_t hash = 17;
            hash = hash * 31 + std::hash<std::string>()(value.name());
            hash = hash * 31 + std::hash<vcpkg::triplet>()(value.target_triplet());
            return hash;
        }
    };

    template <>
    struct equal_to<vcpkg::PackageSpec>
    {
        bool operator()(const vcpkg::PackageSpec& left, const vcpkg::PackageSpec& right) const
        {
            return left == right;
        }
    };
} // namespace std
