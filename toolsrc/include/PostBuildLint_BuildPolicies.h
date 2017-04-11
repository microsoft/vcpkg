#pragma once
#include <string>
#include <array>

namespace vcpkg::PostBuildLint::BuildPolicies
{
    enum class BackingEnum
    {
        NULLVALUE = 0,
        EMPTY_PACKAGE,
        DLLS_WITHOUT_LIBS,
        ONLY_RELEASE_CRT,
        EMPTY_INCLUDE_FOLDER
    };

    struct Type
    {
        constexpr Type() : backing_enum(BackingEnum::NULLVALUE) {}
        constexpr explicit Type(BackingEnum backing_enum) : backing_enum(backing_enum) { }
        constexpr operator BackingEnum() const { return backing_enum; }

        const std::string& to_string() const;
        const std::string& cmake_variable() const;

    private:
        BackingEnum backing_enum;
    };

    static const std::string ENUM_NAME = "vcpkg::PostBuildLint::BuildPolicies";

    static constexpr Type NULLVALUE(BackingEnum::NULLVALUE);
    static constexpr Type EMPTY_PACKAGE(BackingEnum::EMPTY_PACKAGE);
    static constexpr Type DLLS_WITHOUT_LIBS(BackingEnum::DLLS_WITHOUT_LIBS);
    static constexpr Type ONLY_RELEASE_CRT(BackingEnum::ONLY_RELEASE_CRT);
    static constexpr Type EMPTY_INCLUDE_FOLDER(BackingEnum::EMPTY_INCLUDE_FOLDER);

    static constexpr std::array<Type, 4> values = { EMPTY_PACKAGE, DLLS_WITHOUT_LIBS, ONLY_RELEASE_CRT, EMPTY_INCLUDE_FOLDER };

    Type parse(const std::string& s);
}
