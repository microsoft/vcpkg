#pragma once

#include <vcpkg/base/optional.h>

namespace vcpkg
{
    template<typename T>
    class Lazy
    {
    public:
        template<class F>
        T const& get_lazy(const F& f) const
        {
            if (auto p = m_value.get()) return *p;
            m_value = f();
            return *m_value.get();
        }

    private:
        mutable Optional<T> m_value;
    };
}
