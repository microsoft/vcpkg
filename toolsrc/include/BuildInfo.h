#pragma once

#include <unordered_map>
#include "Paragraphs.h"

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

        const ConfigurationType config;
        const LinkageType linkage;

        BuildType() = delete;

        std::string toString() const;

    private:
        BuildType(const ConfigurationType& config, const LinkageType& linkage) : config(config), linkage(linkage)
        {
        }
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
