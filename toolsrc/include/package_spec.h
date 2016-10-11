#pragma once
#include <string>
#include "package_spec_parse_result.h"
#include "triplet.h"
#include "expected.h"

namespace vcpkg
{
    struct package_spec
    {
        static expected<package_spec> from_string(const std::string& spec_as_string, const triplet& default_target_triplet);

        static expected<package_spec> from_name_and_triplet(const std::string& name, const triplet& target_triplet);

        const std::string& name() const;

        const triplet& target_triplet() const;

        std::string dir() const;

    private:
        std::string m_name;
        triplet m_target_triplet;
    };

    std::string to_string(const package_spec& spec);

    std::string to_printf_arg(const package_spec& spec);

    bool operator==(const package_spec& left, const package_spec& right);

    std::ostream& operator<<(std::ostream& os, const package_spec& spec);
} //namespace vcpkg

namespace std
{
    template <>
    struct hash<vcpkg::package_spec>
    {
        size_t operator()(const vcpkg::package_spec& value) const
        {
            size_t hash = 17;
            hash = hash * 31 + std::hash<std::string>()(value.name());
            hash = hash * 31 + std::hash<vcpkg::triplet>()(value.target_triplet());
            return hash;
        }
    };

    template <>
    struct equal_to<vcpkg::package_spec>
    {
        bool operator()(const vcpkg::package_spec& left, const vcpkg::package_spec& right) const
        {
            return left == right;
        }
    };
} // namespace std
