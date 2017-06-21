#pragma once

#include <string>

namespace vcpkg
{
    struct TripletInstance;

    struct Triplet
    {
    public:
        constexpr Triplet() : m_instance(&default_instance) {}

        static Triplet from_canonical_name(const std::string& triplet_as_string);

        static const Triplet X86_WINDOWS;
        static const Triplet X64_WINDOWS;
        static const Triplet X86_UWP;
        static const Triplet X64_UWP;
        static const Triplet ARM_UWP;

        const std::string& canonical_name() const;
        const std::string& to_string() const;
        size_t hash_code() const;

        bool operator==(const Triplet& other) const;

    private:
        static const TripletInstance default_instance;

        constexpr Triplet(const TripletInstance* ptr) : m_instance(ptr) {}

        const TripletInstance* m_instance;
    };

    bool operator!=(const Triplet& left, const Triplet& right);
}

template<>
struct std::hash<vcpkg::Triplet>
{
    size_t operator()(const vcpkg::Triplet& t) const { return t.hash_code(); }
};
