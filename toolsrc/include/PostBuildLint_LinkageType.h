#pragma once
#include <string>

namespace vcpkg::PostBuildLint::LinkageType
{
    enum class backing_enum_t
    {
        NULLVALUE = 0,
        DYNAMIC,
        STATIC
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

    static const std::string ENUM_NAME = "vcpkg::PostBuildLint::LinkageType";

    static constexpr type NULLVALUE(backing_enum_t::NULLVALUE);
    static constexpr type DYNAMIC(backing_enum_t::DYNAMIC);
    static constexpr type STATIC(backing_enum_t::STATIC);

    static constexpr std::array<type, 2> values = { DYNAMIC, STATIC };

    type value_of(const std::string& as_string);
}
