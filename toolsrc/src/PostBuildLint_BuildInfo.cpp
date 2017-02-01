#include "pch.h"
#include  "PostBuildLint_BuildInfo.h"
#include "vcpkg_Checks.h"
#include "opt_bool.h"
#include "vcpkglib_helpers.h"

namespace vcpkg::PostBuildLint
{
    //
    namespace BuildInfoRequiredField
    {
        static const std::string CRT_LINKAGE = "CRTLinkage";
        static const std::string LIBRARY_LINKAGE = "LibraryLinkage";
    }

    BuildInfo BuildInfo::create(std::unordered_map<std::string, std::string> pgh)
    {
        BuildInfo build_info;
        build_info.crt_linkage = details::remove_required_field(&pgh, BuildInfoRequiredField::CRT_LINKAGE);
        build_info.library_linkage = details::remove_required_field(&pgh, BuildInfoRequiredField::LIBRARY_LINKAGE);

        // The remaining entries are policies
        for (const std::unordered_map<std::string, std::string>::value_type& p : pgh)
        {
            const BuildPolicies::type policy = BuildPolicies::parse(p.first);
            Checks::check_exit(policy != BuildPolicies::UNKNOWN, "Unknown policy found: %s", p.first);
            const opt_bool_t status = opt_bool::parse(p.second);
            build_info.policies.emplace(policy, status);
        }

        return build_info;
    }

    BuildInfo read_build_info(const fs::path& filepath)
    {
        const std::vector<std::unordered_map<std::string, std::string>> pghs = Paragraphs::get_paragraphs(filepath);
        Checks::check_exit(pghs.size() == 1, "Invalid BUILD_INFO file for package");

        return BuildInfo::create(pghs[0]);
    }

}
