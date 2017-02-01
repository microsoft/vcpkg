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

    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCP100_DLL = OutdatedDynamicCrt("msvcp100.dll", R"(msvcp100\.dll)");
    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCP100D_DLL = OutdatedDynamicCrt("msvcp100d.dll", R"(msvcp100d\.dll)");
    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCP110_DLL = OutdatedDynamicCrt("msvcp110.dll", R"(msvcp110\.dll)");
    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCP110_WIN_DLL = OutdatedDynamicCrt("msvcp110_win.dll", R"(msvcp110_win\.dll)");
    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCP120_DLL = OutdatedDynamicCrt("msvcp120.dll", R"(msvcp120\.dll)");
    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCP120_CLR0400_DLL = OutdatedDynamicCrt("msvcp120_clr0400.dll", R"(msvcp120_clr0400\.dll)");
    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCP60_DLL = OutdatedDynamicCrt("msvcp60.dll", R"(msvcp60\.dll)");
    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCP_WIN_DLL = OutdatedDynamicCrt("msvcp60.dll", R"(msvcp60\.dll)");;

    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCR100_DLL = OutdatedDynamicCrt("msvcr100.dll", R"(msvcr100\.dll)");
    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCR100D_DLL = OutdatedDynamicCrt("msvcr100d.dll", R"(msvcr100d\.dll)");
    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCR100_CLR0400_DLL = OutdatedDynamicCrt("msvcr100_clr0400.dll", R"(msvcr100_clr0400\.dll)");
    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCR110_DLL = OutdatedDynamicCrt("msvcr110.dll", R"(msvcr110\.dll)");
    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCR120_DLL = OutdatedDynamicCrt("msvcr120.dll", R"(msvcr120\.dll)");
    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCR120_CLR0400_DLL = OutdatedDynamicCrt("msvcr120_clr0400.dll", R"(msvcr120_clr0400\.dll)");
    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCRT_DLL = OutdatedDynamicCrt("msvcrt.dll", R"(msvcrt\.dll)");
    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCRT20_DLL = OutdatedDynamicCrt("msvcrt20.dll", R"(msvcrt20\.dll)");;
    const OutdatedDynamicCrt OutdatedDynamicCrt::MSVCRT40_DLL = OutdatedDynamicCrt("msvcrt40.dll", R"(msvcrt40\.dll)");;

    std::regex OutdatedDynamicCrt::crt_regex() const
    {
        const std::regex r(this->m_crt_regex_as_string, std::regex_constants::icase);
        return r;
    }

    const std::string& OutdatedDynamicCrt::toString() const
    {
        return this->m_dll_name;
    }
}
