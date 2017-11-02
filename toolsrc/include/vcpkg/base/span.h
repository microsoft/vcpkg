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
        using element_type = T;
        using pointer = T*;
        using reference = T&;
        using iterator = T*;

        constexpr Span() noexcept : m_ptr(nullptr), m_count(0) {}
        constexpr Span(std::nullptr_t) noexcept : Span() {}
        constexpr Span(T* ptr, size_t count) noexcept : m_ptr(ptr), m_count(count) {}
        constexpr Span(T* ptr_begin, T* ptr_end) noexcept : m_ptr(ptr_begin), m_count(ptr_end - ptr_begin) {}
        constexpr Span(std::initializer_list<T> l) noexcept : m_ptr(l.begin()), m_count(l.size()) {}

        template<size_t N>
        constexpr Span(T (&arr)[N]) noexcept : Span(arr, N)
        {
        }

        template<size_t N>
        constexpr Span(const std::array<std::remove_const_t<T>, N>& arr) noexcept : Span(arr.data(), arr.size())
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
}