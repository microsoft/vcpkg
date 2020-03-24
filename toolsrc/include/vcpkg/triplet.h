#pragma once

#include <string>
#include <vcpkg/base/system.h>
#include <vcpkg/base/optional.h>

namespace vcpkg
{
    struct TripletInstance;

    struct Triplet
    {
    public:
        constexpr Triplet() noexcept : m_instance(&DEFAULT_INSTANCE) {}

        static Triplet from_canonical_name(std::string&& triplet_as_string);

        static const Triplet X86_WINDOWS;
        static const Triplet X64_WINDOWS;
        static const Triplet ARM_WINDOWS;
        static const Triplet ARM64_WINDOWS;
        static const Triplet X86_UWP;
        static const Triplet X64_UWP;
        static const Triplet ARM_UWP;
        static const Triplet ARM64_UWP;
        
        static const Triplet ARM_ANDROID;
        static const Triplet ARM64_ANDROID;
        static const Triplet X86_ANDROID;
        static const Triplet X64_ANDROID;

        const std::string& canonical_name() const;
        const std::string& to_string() const;
        void to_string(std::string& out) const;
        size_t hash_code() const;
        Optional<System::CPUArchitecture> guess_architecture() const noexcept;

        bool operator==(Triplet other) const { return this->m_instance == other.m_instance; }
        bool operator<(Triplet other) const { return canonical_name() < other.canonical_name(); }

    private:
        static const TripletInstance DEFAULT_INSTANCE;

        constexpr Triplet(const TripletInstance* ptr) : m_instance(ptr) {}

        const TripletInstance* m_instance;
    };

    inline bool operator!=(Triplet left, Triplet right) { return !(left == right); }
}

namespace std
{
    template<>
    struct hash<vcpkg::Triplet>
    {
        size_t operator()(vcpkg::Triplet t) const { return t.hash_code(); }
    };
}
