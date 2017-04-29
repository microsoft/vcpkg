#include "pch.h"

#include "Paragraphs.h"
#include "PostBuildLint_BuildInfo.h"
#include "vcpkg_Checks.h"
#include "vcpkg_optional.h"
#include "vcpkglib_helpers.h"

namespace vcpkg::PostBuildLint
{
    Optional<LinkageType> to_linkagetype(const std::string& str)
    {
        if (str == "dynamic") return LinkageType::DYNAMIC;
        if (str == "static") return LinkageType::STATIC;
        return nullopt;
    }

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
        auto crtlinkage = to_linkagetype(crt_linkage_as_string);
        if (auto p = crtlinkage.get())
            build_info.crt_linkage = *p;
        else
            Checks::exit_with_message(VCPKG_LINE_INFO, "Invalid crt linkage type: [%s]", crt_linkage_as_string);

        const std::string library_linkage_as_string =
            details::remove_required_field(&pgh, BuildInfoRequiredField::LIBRARY_LINKAGE);
        auto liblinkage = to_linkagetype(library_linkage_as_string);
        if (auto p = liblinkage.get())
            build_info.library_linkage = *p;
        else
            Checks::exit_with_message(VCPKG_LINE_INFO, "Invalid library linkage type: [%s]", library_linkage_as_string);

        // The remaining entries are policies
        for (const std::unordered_map<std::string, std::string>::value_type& p : pgh)
        {
            auto policy = to_build_policy(p.first);
            Checks::check_exit(VCPKG_LINE_INFO, policy, "Unknown policy found: %s", p.first);
            if (p.second == "enabled")
                build_info.policies.emplace(policy.value_or_exit(VCPKG_LINE_INFO), true);
            else if (p.second == "disabled")
                build_info.policies.emplace(policy.value_or_exit(VCPKG_LINE_INFO), false);
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
