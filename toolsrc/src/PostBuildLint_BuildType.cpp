#include "pch.h"
#include "PostBuildLint_BuildType.h"
#include "vcpkg_Enums.h"

namespace vcpkg::PostBuildLint::BuildType
{
    type value_of(const ConfigurationType::type& config, const LinkageType::type& linkage)
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

        Enums::unreachable(ENUM_NAME);
    }

    const ConfigurationType::type& type::config() const
    {
        return this->m_config;
    }

    const LinkageType::type& type::linkage() const
    {
        return this->m_linkage;
    }

    const std::regex& type::crt_regex() const
    {
        static const std::regex REGEX_DEBUG_STATIC(R"(/DEFAULTLIB:LIBCMTD)", std::regex_constants::icase);
        static const std::regex REGEX_DEBUG_DYNAMIC(R"(/DEFAULTLIB:MSVCRTD)", std::regex_constants::icase);
        static const std::regex REGEX_RELEASE_STATIC(R"(/DEFAULTLIB:LIBCMT[^D])", std::regex_constants::icase);
        static const std::regex REGEX_RELEASE_DYNAMIC(R"(/DEFAULTLIB:MSVCRT[^D])", std::regex_constants::icase);

        switch (backing_enum)
        {
            case BuildType::DEBUG_STATIC:
                return REGEX_DEBUG_STATIC;
            case BuildType::DEBUG_DYNAMIC:
                return REGEX_DEBUG_DYNAMIC;
            case BuildType::RELEASE_STATIC:
                return REGEX_RELEASE_STATIC;
            case BuildType::RELEASE_DYNAMIC:
                return REGEX_RELEASE_DYNAMIC;
            default:
                Enums::unreachable(ENUM_NAME);
        }
    }

    const std::string& type::toString() const
    {
        static const std::string NAME_DEBUG_STATIC("Debug,Static");
        static const std::string NAME_DEBUG_DYNAMIC("Debug,Dynamic");
        static const std::string NAME_RELEASE_STATIC("Release,Static");
        static const std::string NAME_RELEASE_DYNAMIC("Release,Dynamic");

        switch (backing_enum)
        {
            case BuildType::DEBUG_STATIC:
                return NAME_DEBUG_STATIC;
            case BuildType::DEBUG_DYNAMIC:
                return NAME_DEBUG_DYNAMIC;
            case BuildType::RELEASE_STATIC:
                return NAME_RELEASE_STATIC;
            case BuildType::RELEASE_DYNAMIC:
                return NAME_RELEASE_DYNAMIC;
            default:
                Enums::unreachable(ENUM_NAME);
        }
    }
}
