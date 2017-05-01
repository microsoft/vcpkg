#pragma once
#include "CStringView.h"
#include <string>

namespace vcpkg::PostBuildLint
{
    struct LinkageType final
    {
        enum class BackingEnum
        {
            NULLVALUE = 0,
            DYNAMIC,
            STATIC
        };

        static LinkageType value_of(const std::string& as_string);

        constexpr LinkageType() : backing_enum(BackingEnum::NULLVALUE) {}
        constexpr explicit LinkageType(BackingEnum backing_enum) : backing_enum(backing_enum) {}
        constexpr operator BackingEnum() const { return backing_enum; }

        const std::string& to_string() const;

    private:
        BackingEnum backing_enum;
    };

    namespace LinkageTypeC
    {
        static constexpr CStringView ENUM_NAME = "vcpkg::PostBuildLint::LinkageType";

        static constexpr LinkageType NULLVALUE(LinkageType::BackingEnum::NULLVALUE);
        static constexpr LinkageType DYNAMIC(LinkageType::BackingEnum::DYNAMIC);
        static constexpr LinkageType STATIC(LinkageType::BackingEnum::STATIC);

        static constexpr std::array<LinkageType, 2> VALUES = {DYNAMIC, STATIC};
    }
}
