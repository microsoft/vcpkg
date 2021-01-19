#pragma once

#include <map>

namespace vcpkg
{
    template<class Key, class Value, class Less = std::less<Key>>
    struct Cache
    {
        template<class F>
        Value const& get_lazy(const Key& k, const F& f) const
        {
            auto it = m_cache.find(k);
            if (it != m_cache.end()) return it->second;
            return m_cache.emplace(k, f()).first->second;
        }

    private:
        mutable std::map<Key, Value, Less> m_cache;
    };
}
