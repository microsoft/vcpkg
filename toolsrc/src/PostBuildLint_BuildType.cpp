#include "pch.h"
#include "PostBuildLint_BuildType.h"
#include "vcpkg_Checks.h"

namespace vcpkg::PostBuildLint
{
    const BuildType BuildType::DEBUG_STATIC = BuildType(ConfigurationType::DEBUG, LinkageType::STATIC, R"(/DEFAULTLIB:LIBCMTD)");
    const BuildType BuildType::DEBUG_DYNAMIC = BuildType(ConfigurationType::DEBUG, LinkageType::DYNAMIC, R"(/DEFAULTLIB:MSVCRTD)");
    const BuildType BuildType::RELEASE_STATIC = BuildType(ConfigurationType::RELEASE, LinkageType::STATIC, R"(/DEFAULTLIB:LIBCMT[^D])");
    const BuildType BuildType::RELEASE_DYNAMIC = BuildType(ConfigurationType::RELEASE, LinkageType::DYNAMIC, R"(/DEFAULTLIB:MSVCRT[^D])");

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

    const ConfigurationType& BuildType::config() const
    {
        return this->m_config;
    }

    const LinkageType& BuildType::linkage() const
    {
        return this->m_linkage;
    }

    std::regex BuildType::crt_regex() const
    {
        const std::regex r(this->m_crt_regex_as_string, std::regex_constants::icase);
        return r;
    }

    std::string BuildType::toString() const
    {
        const std::string s = Strings::format("[%s,%s]", to_string(this->m_config), to_string(this->m_linkage));
        return s;
    }

    bool operator==(const BuildType& lhs, const BuildType& rhs)
    {
        return lhs.config() == rhs.config() && lhs.linkage() == rhs.linkage();
    }

    bool operator!=(const BuildType& lhs, const BuildType& rhs)
    {
        return !(lhs == rhs);
    }
}
