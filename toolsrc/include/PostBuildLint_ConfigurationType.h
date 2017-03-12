#pragma once
#pragma once
#include <string>

namespace vcpkg::PostBuildLint::ConfigurationType
{
    enum class backing_enum_t
    {
        NULLVALUE = 0,
        DEBUG = 1,
        RELEASE = 2
    };

    struct type
    {
        constexpr type() : backing_enum(backing_enum_t::NULLVALUE) {}
        constexpr explicit type(backing_enum_t backing_enum) : backing_enum(backing_enum) { }
        constexpr operator backing_enum_t() const { return backing_enum; }

        const std::string& toString() const;

    private:
        backing_enum_t backing_enum;
    };

    static const std::string ENUM_NAME = "vcpkg::PostBuildLint::ConfigurationType";

    static constexpr type NULLVALUE(backing_enum_t::NULLVALUE);
    static constexpr type DEBUG(backing_enum_t::DEBUG);
    static constexpr type RELEASE(backing_enum_t::RELEASE);

    static constexpr std::array<type, 2> values = { DEBUG, RELEASE };
}
