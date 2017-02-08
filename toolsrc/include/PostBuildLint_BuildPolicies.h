#pragma once
#include <string>

namespace vcpkg::PostBuildLint::BuildPolicies
{
    enum class backing_enum_t
    {
        UNKNOWN = 0,
        EMPTY_PACKAGE,
        DLLS_WITHOUT_LIBS
    };

    struct type
    {
        constexpr explicit type(backing_enum_t backing_enum) : backing_enum(backing_enum) { }
        constexpr operator backing_enum_t() const { return backing_enum; }

        const std::string& toString() const;
        const std::string& cmake_variable() const;

    private:
        type();
        backing_enum_t backing_enum;
    };

    static constexpr int value_count = 3;
    const std::vector<type>& values();


    static constexpr type UNKNOWN(backing_enum_t::UNKNOWN);
    static constexpr type EMPTY_PACKAGE(backing_enum_t::EMPTY_PACKAGE);
    static constexpr type DLLS_WITHOUT_LIBS(backing_enum_t::DLLS_WITHOUT_LIBS);

    type parse(const std::string& s);
}
