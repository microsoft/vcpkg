#pragma once

#include <unordered_map>
#include <unordered_set>

namespace vcpkg { namespace Maps
{
    template <typename K, typename V>
    std::unordered_set<K> extract_key_set(const std::unordered_map<K, V>& input_map)
    {
        std::unordered_set<K> key_set;
        for (auto const& element : input_map)
        {
            key_set.insert(element.first);
        }
        return key_set;
    }

    template <typename K, typename V>
    std::vector<K> extract_keys(const std::unordered_map<K, V>& input_map)
    {
        std::vector<K> key_set;
        for (auto const& element : input_map)
        {
            key_set.push_back(element.first);
        }
        return key_set;
    }
}}
