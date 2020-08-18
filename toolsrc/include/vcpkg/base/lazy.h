#pragma once

namespace vcpkg
{
    template<typename T>
    class Lazy
    {
    public:
        Lazy() : value(T()), initialized(false) { }

        template<class F>
        T const& get_lazy(const F& f) const
        {
            if (!initialized)
            {
                value = f();
                initialized = true;
            }
            return value;
        }

    private:
        mutable T value;
        mutable bool initialized;
    };
}
