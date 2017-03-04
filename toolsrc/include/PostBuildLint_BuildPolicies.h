#pragma once
#include <string>
#include <array>

namespace vcpkg::PostBuildLint::BuildPolicies
{
    enum class backing_enum_t
    {
        NULLVALUE = 0,
        EMPTY_PACKAGE,
        DLLS_WITHOUT_LIBS,
        NO_DEBUG_BINARIES
    };

    struct type
    {
        constexpr type() : backing_enum(backing_enum_t::NULLVALUE) {}
        constexpr explicit type(backing_enum_t backing_enum) : backing_enum(backing_enum) { }
        constexpr operator backing_enum_t() const { return backing_enum; }

        const std::string& toString() const;
        const std::string& cmake_variable() const;

    private:
        backing_enum_t backing_enum;
    };

    static const std::string ENUM_NAME = "vcpkg::PostBuildLint::BuildPolicies";

    static constexpr type NULLVALUE(backing_enum_t::NULLVALUE);
    static constexpr type EMPTY_PACKAGE(backing_enum_t::EMPTY_PACKAGE);
    static constexpr type DLLS_WITHOUT_LIBS(backing_enum_t::DLLS_WITHOUT_LIBS);
    static constexpr type NO_DEBUG_BINARIES(backing_enum_t::NO_DEBUG_BINARIES);

    static constexpr std::array<type, 3> values = { EMPTY_PACKAGE, DLLS_WITHOUT_LIBS, NO_DEBUG_BINARIES };

    type parse(const std::string& s);
}
