#pragma once

#include <string>

namespace vcpkg
{
    struct triplet
    {
        static triplet from_canonical_name(const std::string& triplet_as_string);

        static const triplet X86_WINDOWS;
        static const triplet X64_WINDOWS;
        static const triplet X86_UWP;
        static const triplet X64_UWP;
        static const triplet ARM_UWP;

        const std::string& canonical_name() const;

        std::string architecture() const;

        std::string system() const;

    private:
        std::string m_canonical_name;
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
            hash = hash * 31 + hasher(t.canonical_name());
            return hash;
        }
    };

} // namespace std
