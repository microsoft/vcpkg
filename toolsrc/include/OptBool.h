#pragma once

#include <string>
#include <map>

namespace vcpkg
{
    struct OptBool final
    {
        enum class BackingEnum
        {
            UNSPECIFIED = 0,
            ENABLED,
            DISABLED
        };

        static OptBool parse(const std::string& s);

        template<class T>
        static OptBool from_map(const std::map<T, std::string>& map, const T& key);

        constexpr OptBool() : backing_enum(BackingEnum::UNSPECIFIED) {}
        constexpr explicit OptBool(BackingEnum backing_enum) : backing_enum(backing_enum) { }
        constexpr operator BackingEnum() const { return backing_enum; }

    private:
        BackingEnum backing_enum;
    };

    namespace OptBoolC
    {
        constexpr OptBool UNSPECIFIED(OptBool::BackingEnum::UNSPECIFIED);
        constexpr OptBool ENABLED(OptBool::BackingEnum::ENABLED);
        constexpr OptBool DISABLED(OptBool::BackingEnum::DISABLED);
    }

    template<class T>
    OptBool OptBool::from_map(const std::map<T, std::string>& map, const T& key)
    {
        auto it = map.find(key);
        if (it == map.cend())
        {
            return OptBoolC::UNSPECIFIED;
        }

        return parse(*it);
    }
}
