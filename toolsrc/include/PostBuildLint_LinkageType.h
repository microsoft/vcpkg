#pragma once
#include <string>

namespace vcpkg::PostBuildLint::LinkageType
{
    enum class BackingEnum
    {
        NULLVALUE = 0,
        DYNAMIC,
        STATIC
    };

    struct Type
    {
        constexpr Type() : backing_enum(BackingEnum::NULLVALUE) {}
        constexpr explicit Type(BackingEnum backing_enum) : backing_enum(backing_enum) { }
        constexpr operator BackingEnum() const { return backing_enum; }

        const std::string& to_string() const;

    private:
        BackingEnum backing_enum;
    };

    static const std::string ENUM_NAME = "vcpkg::PostBuildLint::LinkageType";

    static constexpr Type NULLVALUE(BackingEnum::NULLVALUE);
    static constexpr Type DYNAMIC(BackingEnum::DYNAMIC);
    static constexpr Type STATIC(BackingEnum::STATIC);

    static constexpr std::array<Type, 2> values = { DYNAMIC, STATIC };

    Type value_of(const std::string& as_string);
}
