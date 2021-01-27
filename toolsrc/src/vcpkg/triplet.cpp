#include <vcpkg/base/strings.h>

#include <vcpkg/triplet.h>
#include <vcpkg/vcpkgcmdarguments.h>

namespace vcpkg
{
    struct TripletInstance
    {
        TripletInstance(std::string&& s) : value(std::move(s)), hash(std::hash<std::string>()(value)) { }

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
    Triplet Triplet::from_canonical_name(std::string&& triplet_as_string)
    {
        static std::unordered_set<TripletInstance> g_triplet_instances;
        std::string s(Strings::ascii_to_lowercase(std::move(triplet_as_string)));
        const auto p = g_triplet_instances.emplace(std::move(s));
        return &*p.first;
    }

    const std::string& Triplet::canonical_name() const { return this->m_instance->value; }

    const std::string& Triplet::to_string() const { return this->canonical_name(); }
    void Triplet::to_string(std::string& out) const { out.append(this->canonical_name()); }
    size_t Triplet::hash_code() const { return m_instance->hash; }

    Optional<System::CPUArchitecture> Triplet::guess_architecture() const noexcept
    {
        using System::CPUArchitecture;
        if (Strings::starts_with(this->canonical_name(), "x86-"))
        {
            return CPUArchitecture::X86;
        }
        if (Strings::starts_with(this->canonical_name(), "x64-"))
        {
            return CPUArchitecture::X64;
        }
        if (Strings::starts_with(this->canonical_name(), "arm-"))
        {
            return CPUArchitecture::ARM;
        }
        if (Strings::starts_with(this->canonical_name(), "arm64-"))
        {
            return CPUArchitecture::ARM64;
        }
        if (Strings::starts_with(this->canonical_name(), "s390x-"))
        {
            return CPUArchitecture::S390X;
        }
        if (Strings::starts_with(this->canonical_name(), "ppc64le-"))
        {
            return CPUArchitecture::PPC64LE;
        }

        return nullopt;
    }

    Triplet default_triplet(const VcpkgCmdArguments& args)
    {
        if (args.triplet != nullptr)
        {
            return Triplet::from_canonical_name(std::string(*args.triplet));
        }
        else
        {
            auto vcpkg_default_triplet_env = System::get_environment_variable("VCPKG_DEFAULT_TRIPLET");
            if (auto v = vcpkg_default_triplet_env.get())
            {
                return Triplet::from_canonical_name(std::move(*v));
            }
            else
            {
#if defined(_WIN32)
                return Triplet::from_canonical_name("x86-windows");
#elif defined(__APPLE__)
                return Triplet::from_canonical_name("x64-osx");
#elif defined(__FreeBSD__)
                return Triplet::from_canonical_name("x64-freebsd");
#elif defined(__OpenBSD__)
                return Triplet::from_canonical_name("x64-openbsd");
#elif defined(__GLIBC__)
#if defined(__aarch64__)
                return Triplet::from_canonical_name("arm64-linux");
#elif defined(__arm__)
                return Triplet::from_canonical_name("arm-linux");
#elif defined(__s390x__)
                return Triplet::from_canonical_name("s390x-linux");
#elif (defined(__ppc64__) || defined(__PPC64__) || defined(__ppc64le__) || defined(__PPC64LE__)) &&                    \
    defined(__BYTE_ORDER__) && (__BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__)
                return Triplet::from_canonical_name("ppc64le-linux");
#else
                return Triplet::from_canonical_name("x64-linux");
#endif
#else
                return Triplet::from_canonical_name("x64-linux-musl");
#endif
            }
        }
    }
}
