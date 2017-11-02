#pragma once

#include <vcpkg/base/cstringview.h>
#include <vcpkg/build.h>

#include <array>
#include <regex>

namespace vcpkg::PostBuildLint
{
    enum class ConfigurationType
    {
        DEBUG,
        RELEASE,
    };

    struct BuildType
    {
        enum class BackingEnum
        {
            DEBUG_STATIC = 1,
            DEBUG_DYNAMIC,
            RELEASE_STATIC,
            RELEASE_DYNAMIC
        };

        static BuildType value_of(const ConfigurationType& config, const Build::LinkageType& linkage);

        BuildType() = delete;

        constexpr BuildType(const BackingEnum backing_enum,
                            const ConfigurationType config,
                            const Build::LinkageType linkage)
            : backing_enum(backing_enum), m_config(config), m_linkage(linkage)
        {
        }

        constexpr operator BackingEnum() const { return backing_enum; }

        const ConfigurationType& config() const;
        const Build::LinkageType& linkage() const;
        const std::regex& crt_regex() const;
        const std::string& to_string() const;

    private:
        BackingEnum backing_enum;
        ConfigurationType m_config;
        Build::LinkageType m_linkage;
    };

    namespace BuildTypeC
    {
        using Build::LinkageType;
        using BE = BuildType::BackingEnum;

        static constexpr CStringView ENUM_NAME = "vcpkg::PostBuildLint::BuildType";

        static constexpr BuildType DEBUG_STATIC = {BE::DEBUG_STATIC, ConfigurationType::DEBUG, LinkageType::STATIC};
        static constexpr BuildType DEBUG_DYNAMIC = {BE::DEBUG_DYNAMIC, ConfigurationType::DEBUG, LinkageType::DYNAMIC};
        static constexpr BuildType RELEASE_STATIC = {
            BE::RELEASE_STATIC, ConfigurationType::RELEASE, LinkageType::STATIC};
        static constexpr BuildType RELEASE_DYNAMIC = {
            BE::RELEASE_DYNAMIC, ConfigurationType::RELEASE, LinkageType::DYNAMIC};

        static constexpr std::array<BuildType, 4> VALUES = {
            DEBUG_STATIC, DEBUG_DYNAMIC, RELEASE_STATIC, RELEASE_DYNAMIC};
    }
}
