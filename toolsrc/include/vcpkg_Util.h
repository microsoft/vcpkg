#pragma once

#include <vector>
#include <utility>

namespace vcpkg::Util
{
    template<class Cont, class Func>
    using FmapOut = decltype(std::declval<Func>()(std::declval<Cont>()[0]));

    template<class Cont, class Func, class Out = FmapOut<Cont, Func>>
    std::vector<Out> fmap(const Cont& xs, Func&& f)
    {
        using O = decltype(f(xs[0]));

        std::vector<O> ret;
        ret.reserve(xs.size());

        for (auto&& x : xs)
            ret.push_back(f(x));

        return ret;
    }

    template<class Container, class Pred>
    void keep_if(Container& cont, Pred pred)
    {
        cont.erase(std::remove_if(cont.begin(), cont.end(), pred), cont.end());
    }
}