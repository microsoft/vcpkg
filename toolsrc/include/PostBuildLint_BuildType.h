#pragma once
#include "PostBuildLint_ConfigurationType.h"
#include "PostBuildLint_LinkageType.h"
#include <vector>
#include <regex>

namespace vcpkg::PostBuildLint
{
    struct BuildType
    {
        static BuildType value_of(const ConfigurationType& config, const LinkageType& linkage);

        static const BuildType DEBUG_STATIC;
        static const BuildType DEBUG_DYNAMIC;
        static const BuildType RELEASE_STATIC;
        static const BuildType RELEASE_DYNAMIC;

        static const std::vector<BuildType>& values()
        {
            static const std::vector<BuildType> v = { DEBUG_STATIC, DEBUG_DYNAMIC, RELEASE_STATIC, RELEASE_DYNAMIC };
            return v;
        }

        BuildType() = delete;

        const ConfigurationType& config() const;
        const LinkageType& linkage() const;
        std::regex crt_regex() const;
        std::string toString() const;

    private:
        BuildType(const ConfigurationType& config, const LinkageType& linkage, const std::string& crt_regex_as_string)
            : m_config(config), m_linkage(linkage), m_crt_regex_as_string(crt_regex_as_string)
        {
        }

        ConfigurationType m_config;
        LinkageType m_linkage;
        std::string m_crt_regex_as_string;
    };

    bool operator ==(const BuildType& lhs, const BuildType& rhs);

    bool operator !=(const BuildType& lhs, const BuildType& rhs);
}
