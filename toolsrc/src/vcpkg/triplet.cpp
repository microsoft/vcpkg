#include "pch.h"

#include <vcpkg/base/strings.h>
#include <vcpkg/triplet.h>

namespace vcpkg
{
    struct TripletInstance
    {
        TripletInstance(std::string&& s) : value(std::move(s)), hash(std::hash<std::string>()(value)) {}

        const std::string value;
        const size_t hash = 0;

        bool operator==(const TripletInstance& o) const { return o.value == value; }
    };
    const TripletInstance Triplet::DEFAULT_INSTANCE({});
}

namespace std
{
    template<>
    struct hash<vcpkg::TripletInstance>
    {
        size_t operator()(const vcpkg::TripletInstance& t) const { return t.hash; }
    };
}

namespace vcpkg
{
    static std::unordered_set<TripletInstance> g_triplet_instances;

    const Triplet Triplet::X86_WINDOWS = from_canonical_name("x86-windows");
    const Triplet Triplet::X64_WINDOWS = from_canonical_name("x64-windows");
    const Triplet Triplet::X86_UWP = from_canonical_name("x86-uwp");
    const Triplet Triplet::X64_UWP = from_canonical_name("x64-uwp");
    const Triplet Triplet::ARM_UWP = from_canonical_name("arm-uwp");
    const Triplet Triplet::ARM64_UWP = from_canonical_name("arm64-uwp");
    const Triplet Triplet::ARM_WINDOWS = from_canonical_name("arm-windows");
    const Triplet Triplet::ARM64_WINDOWS = from_canonical_name("arm64-windows");

    Triplet Triplet::from_canonical_name(std::string&& triplet_as_string)
    {
        std::string s(Strings::ascii_to_lowercase(std::move(triplet_as_string)));
        const auto p = g_triplet_instances.emplace(std::move(s));
        return &*p.first;
    }

    const std::string& Triplet::canonical_name() const { return this->m_instance->value; }

    const std::string& Triplet::to_string() const { return this->canonical_name(); }
    void Triplet::to_string(std::string& out) const { out.append(this->canonical_name()); }
    size_t Triplet::hash_code() const { return m_instance->hash; }
}
