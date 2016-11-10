#pragma once

#include <unordered_map>
#include "Paragraphs.h"
#include <regex>

namespace fs = std::tr2::sys;

namespace vcpkg
{
    enum class LinkageType
    {
        DYNAMIC,
        STATIC,
        UNKNOWN
    };

    LinkageType linkage_type_value_of(const std::string& as_string);

    std::string to_string(const LinkageType& build_info);

    enum class ConfigurationType
    {
        DEBUG = 1,
        RELEASE = 2
    };

    std::string to_string(const ConfigurationType& conf);

    struct BuildType
    {
        static BuildType value_of(const ConfigurationType& config, const LinkageType& linkage);

        static const BuildType DEBUG_STATIC;
        static const BuildType DEBUG_DYNAMIC;
        static const BuildType RELEASE_STATIC;
        static const BuildType RELEASE_DYNAMIC;

        static constexpr int length()
        {
            return 4;
        }

        static const std::vector<BuildType>& values()
        {
            static const std::vector<BuildType> v = {DEBUG_STATIC, DEBUG_DYNAMIC, RELEASE_STATIC, RELEASE_DYNAMIC};
            return v;
        }

        BuildType() = delete;

        const ConfigurationType& config() const;
        const LinkageType& linkage() const;
        const std::regex& crt_regex() const;
        const std::string& toString() const;

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

    struct BuildInfo
    {
        static BuildInfo create(const std::unordered_map<std::string, std::string>& pgh);

        std::string crt_linkage;
        std::string library_linkage;
    };

    BuildInfo read_build_info(const fs::path& filepath);
}
