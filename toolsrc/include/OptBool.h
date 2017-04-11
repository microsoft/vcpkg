#pragma once

#include <string>
#include <map>

namespace vcpkg::OptBool
{
    enum class Type
    {
        UNSPECIFIED = 0,
        ENABLED,
        DISABLED
    };

    Type parse(const std::string& s);

    template <class T>
    Type from_map(const std::map<T, std::string>& map, const T& key)
    {
        auto it = map.find(key);
        if (it == map.cend())
        {
            return Type::UNSPECIFIED;
        }

        return parse(*it);
    }
}

namespace vcpkg
{
    using OptBoolT = OptBool::Type;
}