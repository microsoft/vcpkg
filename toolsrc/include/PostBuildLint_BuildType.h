#pragma once
#include "PostBuildLint_ConfigurationType.h"
#include "PostBuildLint_LinkageType.h"
#include <array>
#include <regex>

namespace vcpkg::PostBuildLint
{
    struct BuildType
    {
        enum class BackingEnum
        {
            DEBUG_STATIC = 1,
            DEBUG_DYNAMIC,
            RELEASE_STATIC,
            RELEASE_DYNAMIC
        };

        static BuildType value_of(const ConfigurationType& config, const LinkageType& linkage);

        BuildType() = delete;

        constexpr explicit BuildType(const BackingEnum backing_enum, const ConfigurationType config, const LinkageType linkage)
            :
            backing_enum(backing_enum)
            , m_config(config)
            , m_linkage(linkage) { }

        constexpr operator BackingEnum() const { return backing_enum; }

        const ConfigurationType& config() const;
        const LinkageType& linkage() const;
        const std::regex& crt_regex() const;
        const std::string& to_string() const;

    private:
        BackingEnum backing_enum;
        ConfigurationType m_config;
        LinkageType m_linkage;
    };

    namespace BuildTypeC
    {
        static constexpr const char* ENUM_NAME = "vcpkg::PostBuildLint::BuildType";

        static constexpr BuildType DEBUG_STATIC = BuildType(BuildType::BackingEnum::DEBUG_STATIC, ConfigurationTypeC::DEBUG, LinkageTypeC::STATIC);
        static constexpr BuildType DEBUG_DYNAMIC = BuildType(BuildType::BackingEnum::DEBUG_DYNAMIC, ConfigurationTypeC::DEBUG, LinkageTypeC::DYNAMIC);
        static constexpr BuildType RELEASE_STATIC = BuildType(BuildType::BackingEnum::RELEASE_STATIC, ConfigurationTypeC::RELEASE, LinkageTypeC::STATIC);
        static constexpr BuildType RELEASE_DYNAMIC = BuildType(BuildType::BackingEnum::RELEASE_DYNAMIC, ConfigurationTypeC::RELEASE, LinkageTypeC::DYNAMIC);

        static constexpr std::array<BuildType, 4> VALUES = { DEBUG_STATIC, DEBUG_DYNAMIC, RELEASE_STATIC, RELEASE_DYNAMIC };
    }}
