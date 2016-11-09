#include  "BuildInfo.h"
#include "vcpkg_Checks.h"
#include "vcpkglib_helpers.h"

namespace vcpkg
{
    std::string BuildType::toString() const
    {
        return Strings::format("[%s,%s]", to_string(config), to_string(linkage));
    }

    bool operator==(const BuildType& lhs, const BuildType& rhs)
    {
        return lhs.config == rhs.config && lhs.linkage == rhs.linkage;
    }

    bool operator!=(const BuildType& lhs, const BuildType& rhs)
    {
        return !(lhs == rhs);
    }

    //
    namespace BuildInfoRequiredField
    {
        static const std::string CRT_LINKAGE = "CRTLinkage";
        static const std::string LIBRARY_LINKAGE = "LibraryLinkage";
    }

    BuildInfo BuildInfo::create(const std::unordered_map<std::string, std::string>& pgh)
    {
        BuildInfo build_info;
        build_info.crt_linkage = details::required_field(pgh, BuildInfoRequiredField::CRT_LINKAGE);
        build_info.library_linkage = details::required_field(pgh, BuildInfoRequiredField::LIBRARY_LINKAGE);

        return build_info;
    }

    const BuildType BuildType::DEBUG_STATIC = BuildType(ConfigurationType::DEBUG, LinkageType::STATIC);
    const BuildType BuildType::DEBUG_DYNAMIC = BuildType(ConfigurationType::DEBUG, LinkageType::DYNAMIC);
    const BuildType BuildType::RELEASE_STATIC = BuildType(ConfigurationType::RELEASE, LinkageType::STATIC);
    const BuildType BuildType::RELEASE_DYNAMIC = BuildType(ConfigurationType::RELEASE, LinkageType::DYNAMIC);

    LinkageType linkage_type_value_of(const std::string& as_string)

    {
        if (as_string == "dynamic")
        {
            return LinkageType::DYNAMIC;
        }

        if (as_string == "static")
        {
            return LinkageType::STATIC;
        }

        return LinkageType::UNKNOWN;
    }

    std::string to_string(const LinkageType& build_info)
    {
        switch (build_info)
        {
            case LinkageType::STATIC:
                return "static";
            case LinkageType::DYNAMIC:
                return "dynamic";
            default:
                Checks::unreachable();
        }
    }

    std::string to_string(const ConfigurationType& conf)

    {
        switch (conf)
        {
            case ConfigurationType::DEBUG:
                return "Debug";
            case ConfigurationType::RELEASE:
                return "Release";
            default:
                Checks::unreachable();
        }
    }

    BuildType BuildType::value_of(const ConfigurationType& config, const LinkageType& linkage)
    {
        if (config == ConfigurationType::DEBUG && linkage == LinkageType::STATIC)
        {
            return DEBUG_STATIC;
        }

        if (config == ConfigurationType::DEBUG && linkage == LinkageType::DYNAMIC)
        {
            return DEBUG_DYNAMIC;
        }

        if (config == ConfigurationType::RELEASE && linkage == LinkageType::STATIC)
        {
            return RELEASE_STATIC;
        }

        if (config == ConfigurationType::RELEASE && linkage == LinkageType::DYNAMIC)
        {
            return RELEASE_DYNAMIC;
        }

        Checks::unreachable();
    }

    BuildInfo read_build_info(const fs::path& filepath)
    {
        const std::vector<std::unordered_map<std::string, std::string>> pghs = Paragraphs::get_paragraphs(filepath);
        Checks::check_throw(pghs.size() == 1, "Invalid BUILD_INFO file for package");

        return BuildInfo::create(pghs[0]);
    }
}
