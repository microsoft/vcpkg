#pragma once

#include <string>

namespace vcpkg
{
    struct Triplet
    {
        static Triplet from_canonical_name(const std::string& triplet_as_string);

        static const Triplet X86_WINDOWS;
        static const Triplet X64_WINDOWS;
        static const Triplet X86_UWP;
        static const Triplet X64_UWP;
        static const Triplet ARM_UWP;

        const std::string& canonical_name() const;
        std::string architecture() const;
        std::string system() const;
        const std::string& to_string() const;

    private:
        std::string m_canonical_name;
    };

    bool operator==(const Triplet& left, const Triplet& right);

    bool operator!=(const Triplet& left, const Triplet& right);
}

namespace std
{
    template <>
    struct hash<vcpkg::Triplet>
    {
        size_t operator()(const vcpkg::Triplet& t) const
        {
            std::hash<std::string> hasher;
            size_t hash = 17;
            hash = hash * 31 + hasher(t.canonical_name());
            return hash;
        }
    };

} // namespace std
