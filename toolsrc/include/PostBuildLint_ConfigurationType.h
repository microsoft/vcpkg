#pragma once
#pragma once
#include <string>

namespace vcpkg::PostBuildLint::ConfigurationType
{
    enum class BackingEnum
    {
        NULLVALUE = 0,
        DEBUG = 1,
        RELEASE = 2
    };

    struct Type
    {
        constexpr Type() : backing_enum(BackingEnum::NULLVALUE) {}
        constexpr explicit Type(BackingEnum backing_enum) : backing_enum(backing_enum) { }
        constexpr operator BackingEnum() const { return backing_enum; }

        const std::string& toString() const;

    private:
        BackingEnum backing_enum;
    };

    static const std::string ENUM_NAME = "vcpkg::PostBuildLint::ConfigurationType";

    static constexpr Type NULLVALUE(BackingEnum::NULLVALUE);
    static constexpr Type DEBUG(BackingEnum::DEBUG);
    static constexpr Type RELEASE(BackingEnum::RELEASE);

    static constexpr std::array<Type, 2> values = { DEBUG, RELEASE };
}
