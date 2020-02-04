#include <vcpkg-test/mockcmakevarprovider.h>

namespace vcpkg::Test
{
    Optional<const std::unordered_map<std::string, std::string>&> MockCMakeVarProvider::get_generic_triplet_vars(
        const Triplet& triplet) const
    {
        auto it = generic_triplet_vars.find(triplet);
        if (it == generic_triplet_vars.end()) return nullopt;
        return it->second;
    }

    Optional<const std::unordered_map<std::string, std::string>&> MockCMakeVarProvider::get_dep_info_vars(
        const PackageSpec& spec) const
    {
        auto it = dep_info_vars.find(spec);
        if (it == dep_info_vars.end()) return nullopt;
        return it->second;
    }

    Optional<const std::unordered_map<std::string, std::string>&> MockCMakeVarProvider::get_tag_vars(
        const PackageSpec& spec) const
    {
        auto it = tag_vars.find(spec);
        if (it == tag_vars.end()) return nullopt;
        return it->second;
    }
}