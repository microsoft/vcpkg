#pragma once

#include <vcpkg/base/optional.h>
#include <vcpkg/base/view.h>

#include <algorithm>
#include <functional>
#include <map>
#include <type_traits>
#include <unordered_map>
#include <utility>
#include <vector>

namespace vcpkg::Util
{
    template<class Container>
    using ElementT =
        std::remove_reference_t<decltype(*std::declval<typename std::remove_reference_t<Container>::iterator>())>;

    namespace Vectors
    {
        template<class Container, class T = ElementT<Container>>
        void append(std::vector<T>* augend, const Container& addend)
        {
            augend->insert(augend->end(), addend.begin(), addend.end());
        }
        template<class Vec, class Key>
        bool contains(const Vec& container, const Key& item)
        {
            return std::find(container.begin(), container.end(), item) != container.end();
        }
        template<class T>
        std::vector<T> concat(View<T> r1, View<T> r2)
        {
            std::vector<T> v;
            v.reserve(r1.size() + r2.size());
            v.insert(v.end(), r1.begin(), r1.end());
            v.insert(v.end(), r2.begin(), r2.end());
            return v;
        }
    }

    namespace Sets
    {
        template<class Container, class Key>
        bool contains(const Container& container, const Key& item)
        {
            return container.find(item) != container.end();
        }
    }

    namespace Maps
    {
        template<class K, class V1, class V2, class Func>
        void transform_values(const std::unordered_map<K, V1>& container, std::unordered_map<K, V2>& output, Func func)
        {
            std::for_each(container.cbegin(), container.cend(), [&](const std::pair<const K, V1>& p) {
                output[p.first] = func(p.second);
            });
        }
    }

    template<class Range, class Pred, class E = ElementT<Range>>
    std::vector<E> filter(const Range& xs, Pred&& f)
    {
        std::vector<E> ret;

        for (auto&& x : xs)
        {
            if (f(x)) ret.push_back(x);
        }

        return ret;
    }

    template<class Range, class Func>
    using FmapRefOut = decltype(std::declval<Func&>()(*std::declval<Range>().begin()));

    template<class Range, class Func>
    using FmapOut = std::decay_t<FmapRefOut<Range, Func>>;

    template<class Range, class Func, class Out = FmapOut<Range, Func>>
    std::vector<Out> fmap(Range&& xs, Func&& f)
    {
        std::vector<Out> ret;
        ret.reserve(xs.size());

        for (auto&& x : xs)
            ret.push_back(f(x));

        return ret;
    }

    template<class Range, class Proj, class Out = FmapRefOut<Range, Proj>>
    Optional<Out> common_projection(Range&& input, Proj&& proj)
    {
        const auto last = input.end();
        auto first = input.begin();
        if (first == last)
        {
            return nullopt;
        }

        Out prototype = proj(*first);
        while (++first != last)
        {
            if (prototype != proj(*first))
            {
                return nullopt;
            }
        }

        return prototype;
    }

    template<class Cont, class Func>
    using FmapFlattenOut = std::decay_t<decltype(*begin(std::declval<Func>()(*begin(std::declval<Cont>()))))>;

    template<class Cont, class Func, class Out = FmapFlattenOut<Cont, Func>>
    std::vector<Out> fmap_flatten(Cont&& xs, Func&& f)
    {
        std::vector<Out> ret;

        for (auto&& x : xs)
            for (auto&& y : f(x))
                ret.push_back(std::move(y));

        return ret;
    }

    template<class Container, class Pred>
    void erase_remove_if(Container& cont, Pred pred)
    {
        cont.erase(std::remove_if(cont.begin(), cont.end(), pred), cont.end());
    }

    template<class Container, class V>
    auto find(Container&& cont, V&& v)
    {
        using std::begin;
        using std::end;
        return std::find(begin(cont), end(cont), v);
    }

    template<class Container, class Pred>
    auto find_if(Container&& cont, Pred pred)
    {
        using std::begin;
        using std::end;
        return std::find_if(begin(cont), end(cont), pred);
    }

    template<class Container, class Pred>
    auto find_if_not(Container&& cont, Pred pred)
    {
        using std::begin;
        using std::end;
        return std::find_if_not(begin(cont), end(cont), pred);
    }

    template<class K, class V, class Container, class Func>
    void group_by(const Container& cont, std::map<K, std::vector<const V*>>* output, Func&& f)
    {
        for (const V& element : cont)
        {
            K key = f(element);
            (*output)[key].push_back(&element);
        }
    }

    template<class Range, class Comp = std::less<typename Range::value_type>>
    void sort(Range& cont, Comp comp = Comp())
    {
        using std::begin;
        using std::end;
        std::sort(begin(cont), end(cont), comp);
    }

    template<class Range, class Pred>
    bool any_of(Range&& rng, Pred pred)
    {
        return std::any_of(rng.begin(), rng.end(), std::move(pred));
    }

    template<class Range>
    Range&& sort_unique_erase(Range&& cont)
    {
        using std::begin;
        using std::end;
        std::sort(begin(cont), end(cont));
        cont.erase(std::unique(begin(cont), end(cont)), end(cont));

        return std::forward<Range>(cont);
    }

    template<class Range1, class Range2>
    bool all_equal(const Range1& r1, const Range2& r2)
    {
        using std::begin;
        using std::end;
        return std::equal(begin(r1), end(r1), begin(r2), end(r2));
    }

    template<class AssocContainer, class K = std::decay_t<decltype(begin(std::declval<AssocContainer>())->first)>>
    std::vector<K> extract_keys(AssocContainer&& input_map)
    {
        return fmap(input_map, [](auto&& p) { return p.first; });
    }

    struct MoveOnlyBase
    {
        MoveOnlyBase() = default;
        MoveOnlyBase(const MoveOnlyBase&) = delete;
        MoveOnlyBase(MoveOnlyBase&&) = default;

        MoveOnlyBase& operator=(const MoveOnlyBase&) = delete;
        MoveOnlyBase& operator=(MoveOnlyBase&&) = default;

        ~MoveOnlyBase() = default;
    };

    struct ResourceBase
    {
        ResourceBase() = default;
        ResourceBase(const ResourceBase&) = delete;
        ResourceBase(ResourceBase&&) = delete;

        ResourceBase& operator=(const ResourceBase&) = delete;
        ResourceBase& operator=(ResourceBase&&) = delete;

        ~ResourceBase() = default;
    };

    namespace Enum
    {
        template<class E>
        E to_enum(bool b)
        {
            return b ? E::YES : E::NO;
        }

        template<class E>
        bool to_bool(E e)
        {
            return e == E::YES;
        }
    }
}
