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
        ONLY_RELEASE_CRT,
        EMPTY_INCLUDE_FOLDER
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
    static constexpr type ONLY_RELEASE_CRT(backing_enum_t::ONLY_RELEASE_CRT);
    static constexpr type EMPTY_INCLUDE_FOLDER(backing_enum_t::EMPTY_INCLUDE_FOLDER);

    static constexpr std::array<type, 4> values = { EMPTY_PACKAGE, DLLS_WITHOUT_LIBS, ONLY_RELEASE_CRT, EMPTY_INCLUDE_FOLDER };

    type parse(const std::string& s);
}
