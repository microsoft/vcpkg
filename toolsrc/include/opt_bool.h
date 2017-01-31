#pragma once

#include <string>
#include <map>

namespace vcpkg::opt_bool
{
    enum class type
    {
        UNSPECIFIED = 0,
        ENABLED,
        DISABLED
    };

    type parse(const std::string& s);

    template <class T>
    type from_map(const std::map<T, std::string>& map, const T& key)
    {
        auto it = map.find(key);
        if (it == map.cend())
        {
            return type::UNSPECIFIED;
        }

        return parse(*it);
    }
}

namespace vcpkg
{
    using opt_bool_t = opt_bool::type;
}