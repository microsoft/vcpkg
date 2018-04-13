#pragma once

#include <array>
#include <cstddef>
#include <initializer_list>
#include <vector>

namespace vcpkg
{
    template<class T>
    struct Span
    {
    public:
        static_assert(!std::is_reference<T>::value, "Span<&> is illegal");

        using element_type = T;
        using pointer = std::add_pointer_t<T>;
        using reference = std::add_lvalue_reference_t<T>;
        using iterator = pointer;

        constexpr Span() noexcept : m_ptr(nullptr), m_count(0) {}
        constexpr Span(std::nullptr_t) noexcept : m_ptr(nullptr), m_count(0) {}
        constexpr Span(pointer ptr, size_t count) noexcept : m_ptr(ptr), m_count(count) {}
        constexpr Span(pointer ptr_begin, pointer ptr_end) noexcept : m_ptr(ptr_begin), m_count(ptr_end - ptr_begin) {}
        constexpr Span(std::initializer_list<T> l) noexcept : m_ptr(l.begin()), m_count(l.size()) {}

        template<size_t N>
        constexpr Span(T (&arr)[N]) noexcept : m_ptr(arr), m_count(N)
        {
        }

        template<size_t N>
        constexpr Span(const std::array<std::remove_const_t<T>, N>& arr) noexcept
            : m_ptr(arr.data()), m_count(arr.size())
        {
        }

        Span(std::vector<T>& v) noexcept : Span(v.data(), v.size()) {}
        Span(const std::vector<std::remove_const_t<T>>& v) noexcept : Span(v.data(), v.size()) {}

        constexpr iterator begin() const { return m_ptr; }
        constexpr iterator end() const { return m_ptr + m_count; }

        constexpr reference operator[](size_t i) const { return m_ptr[i]; }
        constexpr size_t size() const { return m_count; }

    private:
        pointer m_ptr;
        size_t m_count;
    };

    template<class T>
    Span<T> make_span(std::vector<T>& v)
    {
        return {v.data(), v.size()};
    }

    template<class T>
    Span<const T> make_span(const std::vector<T>& v)
    {
        return {v.data(), v.size()};
    }

    template<class T>
    constexpr T* begin(Span<T> sp)
    {
        return sp.begin();
    }

    template<class T>
    constexpr T* end(Span<T> sp)
    {
        return sp.end();
    }
}
