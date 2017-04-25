#pragma once
#include <string>
#include <array>

namespace vcpkg::PostBuildLint
{
    struct BuildPolicies final
    {
        enum class BackingEnum
        {
            NULLVALUE = 0,
            EMPTY_PACKAGE,
            DLLS_WITHOUT_LIBS,
            ONLY_RELEASE_CRT,
            EMPTY_INCLUDE_FOLDER
        };

        static BuildPolicies parse(const std::string& s);

        constexpr BuildPolicies() : backing_enum(BackingEnum::NULLVALUE) {}
        constexpr explicit BuildPolicies(BackingEnum backing_enum) : backing_enum(backing_enum) { }
        constexpr operator BackingEnum() const { return backing_enum; }

        const std::string& to_string() const;
        const std::string& cmake_variable() const;

    private:
        BackingEnum backing_enum;
    };

    static const std::string ENUM_NAME = "vcpkg::PostBuildLint::BuildPolicies";

    namespace BuildPoliciesC
    {
        constexpr BuildPolicies NULLVALUE(BuildPolicies::BackingEnum::NULLVALUE);
        constexpr BuildPolicies EMPTY_PACKAGE(BuildPolicies::BackingEnum::EMPTY_PACKAGE);
        constexpr BuildPolicies DLLS_WITHOUT_LIBS(BuildPolicies::BackingEnum::DLLS_WITHOUT_LIBS);
        constexpr BuildPolicies ONLY_RELEASE_CRT(BuildPolicies::BackingEnum::ONLY_RELEASE_CRT);
        constexpr BuildPolicies EMPTY_INCLUDE_FOLDER(BuildPolicies::BackingEnum::EMPTY_INCLUDE_FOLDER);

        constexpr std::array<BuildPolicies, 4> VALUES = { EMPTY_PACKAGE,DLLS_WITHOUT_LIBS, ONLY_RELEASE_CRT, EMPTY_INCLUDE_FOLDER };
    }}
