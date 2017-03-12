#pragma once
#include "PostBuildLint_ConfigurationType.h"
#include "PostBuildLint_LinkageType.h"
#include <array>
#include <regex>

namespace vcpkg::PostBuildLint::BuildType
{
    enum class backing_enum_t
    {
        DEBUG_STATIC = 1,
        DEBUG_DYNAMIC,
        RELEASE_STATIC,
        RELEASE_DYNAMIC
    };

    struct type
    {
        type() = delete;

        constexpr explicit type(const backing_enum_t backing_enum, const ConfigurationType::type config, const LinkageType::type linkage) :
            backing_enum(backing_enum), m_config(config), m_linkage(linkage) { }

        constexpr operator backing_enum_t() const { return backing_enum; }

        const ConfigurationType::type& config() const;
        const LinkageType::type& linkage() const;
        const std::regex& crt_regex() const;
        const std::string& toString() const;

    private:
        backing_enum_t backing_enum;
        ConfigurationType::type m_config;
        LinkageType::type m_linkage;
    };

    static const std::string ENUM_NAME = "vcpkg::PostBuildLint::BuildType";

    static constexpr type DEBUG_STATIC = type(backing_enum_t::DEBUG_STATIC, ConfigurationType::DEBUG, LinkageType::STATIC);
    static constexpr type DEBUG_DYNAMIC = type(backing_enum_t::DEBUG_DYNAMIC, ConfigurationType::DEBUG, LinkageType::DYNAMIC);
    static constexpr type RELEASE_STATIC = type(backing_enum_t::RELEASE_STATIC, ConfigurationType::RELEASE, LinkageType::STATIC);
    static constexpr type RELEASE_DYNAMIC = type(backing_enum_t::RELEASE_DYNAMIC, ConfigurationType::RELEASE, LinkageType::DYNAMIC);

    static constexpr std::array<type, 4> values = { DEBUG_STATIC, DEBUG_DYNAMIC, RELEASE_STATIC, RELEASE_DYNAMIC };

    type value_of(const ConfigurationType::type& config, const LinkageType::type& linkage);
}
