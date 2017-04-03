#include "pch.h"
#include  "PostBuildLint_BuildInfo.h"
#include "vcpkg_Checks.h"
#include "OptBool.h"
#include "vcpkglib_helpers.h"
#include "Paragraphs.h"

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
        const std::string crt_linkage_as_string = details::remove_required_field(&pgh, BuildInfoRequiredField::CRT_LINKAGE);
        build_info.crt_linkage = LinkageType::value_of(crt_linkage_as_string);
        Checks::check_exit(VCPKG_LINE_INFO, build_info.crt_linkage != LinkageType::NULLVALUE, "Invalid crt linkage type: [%s]", crt_linkage_as_string);

        const std::string library_linkage_as_string = details::remove_required_field(&pgh, BuildInfoRequiredField::LIBRARY_LINKAGE);
        build_info.library_linkage = LinkageType::value_of(library_linkage_as_string);
        Checks::check_exit(VCPKG_LINE_INFO, build_info.library_linkage != LinkageType::NULLVALUE, "Invalid library linkage type: [%s]", library_linkage_as_string);

        // The remaining entries are policies
        for (const std::unordered_map<std::string, std::string>::value_type& p : pgh)
        {
            const BuildPolicies::Type policy = BuildPolicies::parse(p.first);
            Checks::check_exit(VCPKG_LINE_INFO, policy != BuildPolicies::NULLVALUE, "Unknown policy found: %s", p.first);
            const OptBoolT status = OptBool::parse(p.second);
            build_info.policies.emplace(policy, status);
        }

        return build_info;
    }

    BuildInfo read_build_info(const fs::path& filepath)
    {
        const expected<std::unordered_map<std::string, std::string>> pghs = Paragraphs::get_single_paragraph(filepath);
        Checks::check_exit(VCPKG_LINE_INFO, pghs.get() != nullptr, "Invalid BUILD_INFO file for package");
        return BuildInfo::create(*pghs.get());
    }
}
