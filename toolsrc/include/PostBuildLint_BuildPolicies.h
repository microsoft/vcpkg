#pragma once
#include <array>
#include <string>

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
        constexpr explicit BuildPolicies(BackingEnum backing_enum) : backing_enum(backing_enum) {}
        constexpr operator BackingEnum() const { return backing_enum; }

        const std::string& to_string() const;
        const std::string& cmake_variable() const;

    private:
        BackingEnum backing_enum;
    };

    namespace BuildPoliciesC
    {
        static constexpr const char* ENUM_NAME = "vcpkg::PostBuildLint::BuildPolicies";

        static constexpr BuildPolicies NULLVALUE(BuildPolicies::BackingEnum::NULLVALUE);
        static constexpr BuildPolicies EMPTY_PACKAGE(BuildPolicies::BackingEnum::EMPTY_PACKAGE);
        static constexpr BuildPolicies DLLS_WITHOUT_LIBS(BuildPolicies::BackingEnum::DLLS_WITHOUT_LIBS);
        static constexpr BuildPolicies ONLY_RELEASE_CRT(BuildPolicies::BackingEnum::ONLY_RELEASE_CRT);
        static constexpr BuildPolicies EMPTY_INCLUDE_FOLDER(BuildPolicies::BackingEnum::EMPTY_INCLUDE_FOLDER);

        static constexpr std::array<BuildPolicies, 4> VALUES = {
            EMPTY_PACKAGE, DLLS_WITHOUT_LIBS, ONLY_RELEASE_CRT, EMPTY_INCLUDE_FOLDER};
    }
}
