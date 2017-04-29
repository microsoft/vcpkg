#include "pch.h"

#include "Paragraphs.h"
#include "PostBuildLint_BuildInfo.h"
#include "vcpkg_Checks.h"
#include "vcpkg_optional.h"
#include "vcpkglib_helpers.h"

namespace vcpkg::PostBuildLint
{
    namespace BuildInfoRequiredField
    {
        static const std::string CRT_LINKAGE = "CRTLinkage";
        static const std::string LIBRARY_LINKAGE = "LibraryLinkage";
    }

    BuildInfo BuildInfo::create(std::unordered_map<std::string, std::string> pgh)
    {
        BuildInfo build_info;
        const std::string crt_linkage_as_string =
            details::remove_required_field(&pgh, BuildInfoRequiredField::CRT_LINKAGE);
        build_info.crt_linkage = LinkageType::value_of(crt_linkage_as_string);
        Checks::check_exit(VCPKG_LINE_INFO,
                           build_info.crt_linkage != LinkageTypeC::NULLVALUE,
                           "Invalid crt linkage type: [%s]",
                           crt_linkage_as_string);

        const std::string library_linkage_as_string =
            details::remove_required_field(&pgh, BuildInfoRequiredField::LIBRARY_LINKAGE);
        build_info.library_linkage = LinkageType::value_of(library_linkage_as_string);
        Checks::check_exit(VCPKG_LINE_INFO,
                           build_info.library_linkage != LinkageTypeC::NULLVALUE,
                           "Invalid library linkage type: [%s]",
                           library_linkage_as_string);

        // The remaining entries are policies
        for (const std::unordered_map<std::string, std::string>::value_type& p : pgh)
        {
            const BuildPolicies policy = BuildPolicies::parse(p.first);
            Checks::check_exit(
                VCPKG_LINE_INFO, policy != BuildPoliciesC::NULLVALUE, "Unknown policy found: %s", p.first);
            if (p.second == "enabled")
                build_info.policies.emplace(policy, true);
            else if (p.second == "disabled")
                build_info.policies.emplace(policy, false);
            else
                Checks::exit_with_message(VCPKG_LINE_INFO, "Unknown setting for policy '%s': %s", p.first, p.second);
        }

        return build_info;
    }

    BuildInfo read_build_info(const Files::Filesystem& fs, const fs::path& filepath)
    {
        const Expected<std::unordered_map<std::string, std::string>> pghs =
            Paragraphs::get_single_paragraph(fs, filepath);
        Checks::check_exit(VCPKG_LINE_INFO, pghs.get() != nullptr, "Invalid BUILD_INFO file for package");
        return BuildInfo::create(*pghs.get());
    }
}
