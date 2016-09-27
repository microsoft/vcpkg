#pragma once

#include <string>

namespace vcpkg
{
    struct vcpkg_paths;

    struct triplet
    {
        static const triplet X86_WINDOWS;
        static const triplet X64_WINDOWS;
        static const triplet X86_UWP;
        static const triplet X64_UWP;
        static const triplet ARM_UWP;

        std::string value;

        std::string architecture() const;

        std::string system() const;

        bool validate(const vcpkg_paths& paths) const;
    };

    bool operator==(const triplet& left, const triplet& right);

    bool operator!=(const triplet& left, const triplet& right);

    std::string to_string(const triplet& spec);

    std::string to_printf_arg(const triplet& spec);

    std::ostream& operator<<(std::ostream& os, const triplet& spec);
}

namespace std
{
    template <>
    struct hash<vcpkg::triplet>
    {
        size_t operator()(const vcpkg::triplet& t) const
        {
            std::hash<std::string> hasher;
            size_t hash = 17;
            hash = hash * 31 + hasher(t.value);
            return hash;
        }
    };

    template <>
    struct equal_to<vcpkg::triplet>
    {
        bool operator()(const vcpkg::triplet& left, const vcpkg::triplet& right) const
        {
            return left == right;
        }
    };
} // namespace std
