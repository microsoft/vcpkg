#pragma once
#pragma once
#include <string>

namespace vcpkg::PostBuildLint
{
    struct ConfigurationType
    {
        enum class BackingEnum
        {
            NULLVALUE = 0,
            DEBUG = 1,
            RELEASE = 2
        };

        constexpr ConfigurationType() : backing_enum(BackingEnum::NULLVALUE) {}
        constexpr explicit ConfigurationType(BackingEnum backing_enum) : backing_enum(backing_enum) { }
        constexpr operator BackingEnum() const { return backing_enum; }

        const std::string& to_string() const;

    private:
        BackingEnum backing_enum;
    };

    namespace ConfigurationTypeC
    {
        static constexpr const char* ENUM_NAME = "vcpkg::PostBuildLint::ConfigurationType";

        static constexpr ConfigurationType NULLVALUE(ConfigurationType::BackingEnum::NULLVALUE);
        static constexpr ConfigurationType DEBUG(ConfigurationType::BackingEnum::DEBUG);
        static constexpr ConfigurationType RELEASE(ConfigurationType::BackingEnum::RELEASE);

        static constexpr std::array<ConfigurationType, 2> VALUES = { DEBUG, RELEASE };
    }
}
