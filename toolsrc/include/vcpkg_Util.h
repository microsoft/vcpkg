#pragma once

#include <map>
#include <mutex>
#include <utility>
#include <vector>

namespace vcpkg::Util
{
    template<class Cont, class Func>
    using FmapOut = decltype(std::declval<Func>()(*begin(std::declval<Cont>())));

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
    auto find(const Container& cont, V&& v)
    {
        return std::find(cont.cbegin(), cont.cend(), v);
    }

    template<class Container, class Pred>
    auto find_if(const Container& cont, Pred pred)
    {
        return std::find_if(cont.cbegin(), cont.cend(), pred);
    }

    template<class Container, class Pred>
    auto find_if_not(const Container& cont, Pred pred)
    {
        return std::find_if_not(cont.cbegin(), cont.cend(), pred);
    }

    template<class K, class V, class Container, class Func>
    void group_by(const Container& cont, std::map<K, std::vector<const V*>>* output, Func f)
    {
        for (const V& element : cont)
        {
            K key = f(element);
            (*output)[key].push_back(&element);
        }
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
}