#pragma once

#include <algorithm>
#include <functional>
#include <map>
#include <mutex>
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
        void concatenate(std::vector<T>* augend, const Container& addend)
        {
            augend->insert(augend->end(), addend.begin(), addend.end());
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

    /*
    namespace Ranges
    {
        template<class... Iters>
        struct ChainedRange;

        // InputIterator
        template<class... Iters>
        struct ChainedRangeIterator
        {
            ChainedRangeIterator() : m_parent(nullptr) {}
            ChainedRangeIterator(ChainedRange<Iters...>& parent) : m_parent(&parent)
            {
                if (m_parent->empty()) m_parent = nullptr;
            }

            auto operator*() const { return m_parent->; }

        private:
            ChainedRange<Iters...>* m_parent;
        };

        template<class Iter>
        struct ChainedRange<Iter>
        {
            auto operator*() const { return *b; }
            void next() { ++b; }
            Iter b, e;
        };

        template<class Iter, class... Iters>
        struct ChainedRange<Iter, Iters...> : ChainedRange<Iters...>
        {
            auto operator*() const { return b == e ? ChainedRange<Iters...>::operator*() : *b; }
            void next() { b == e ? ChainedRange<Iters...>::next() : ++b; }

            Iter b, e;
        };
    }*/

    template<class Range, class Func>
    using FmapOut = std::remove_reference_t<decltype(std::declval<Func&>()(*std::declval<Range>().begin()))>;

    template<class Range, class Func, class Out = FmapOut<Range, Func>>
    std::vector<Out> fmap(Range&& xs, Func&& f)
    {
        std::vector<Out> ret;
        ret.reserve(xs.size());

        for (auto&& x : xs)
            ret.push_back(f(x));

        return ret;
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

    template<class T>
    struct LockGuardPtr;

    template<class T>
    struct LockGuarded
    {
        friend struct LockGuardPtr<T>;

        LockGuardPtr<T> lock() { return *this; }

    private:
        std::mutex m_mutex;
        T m_t;
    };

    template<class T>
    struct LockGuardPtr
    {
        T& operator*() { return m_ptr; }
        T* operator->() { return &m_ptr; }

        T* get() { return &m_ptr; }

        LockGuardPtr(LockGuarded<T>& sync) : m_lock(sync.m_mutex), m_ptr(sync.m_t) {}

    private:
        std::unique_lock<std::mutex> m_lock;
        T& m_ptr;
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

    template<class... Ts>
    void unused(const Ts&...)
    {
    }

    template<class T>
    T copy(const T& t)
    {
        return t;
    }
}
