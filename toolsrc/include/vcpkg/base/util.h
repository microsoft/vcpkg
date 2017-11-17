#pragma once

#include <algorithm>
#include <map>
#include <mutex>
#include <utility>
#include <vector>

#include <vcpkg/base/optional.h>

namespace vcpkg::Util
{
    template<class Container>
    using ElementT = std::remove_reference_t<decltype(*begin(std::declval<Container>()))>;

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
        template<class Container>
        bool contains(const Container& container, const ElementT<Container>& item)
        {
            return container.find(item) != container.cend();
        }
    }

    template<class Cont, class Func>
    using FmapOut = decltype(std::declval<Func&>()(*begin(std::declval<Cont&>())));

    template<class Cont, class Func, class Out = FmapOut<Cont, Func>>
    std::vector<Out> fmap(Cont&& xs, Func&& f)
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
    void stable_keep_if(Container& cont, Pred pred)
    {
        cont.erase(std::stable_partition(cont.begin(), cont.end(), pred), cont.end());
    }

    template<class Container, class Pred>
    void unstable_keep_if(Container& cont, Pred pred)
    {
        cont.erase(std::partition(cont.begin(), cont.end(), pred), cont.end());
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

    template<class Container, class T = ElementT<Container>>
    std::vector<T*> element_pointers(Container&& cont)
    {
        return fmap(cont, [](auto&& x) { return &x; });
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

    template<class Range>
    void sort(Range& cont)
    {
        using std::begin;
        using std::end;
        std::sort(begin(cont), end(cont));
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
    };

    struct ResourceBase
    {
        ResourceBase() = default;
        ResourceBase(const ResourceBase&) = delete;
        ResourceBase(ResourceBase&&) = delete;

        ResourceBase& operator=(const ResourceBase&) = delete;
        ResourceBase& operator=(ResourceBase&&) = delete;
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
}
