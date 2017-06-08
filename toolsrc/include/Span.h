#pragma once

#include <array>
#include <cstddef>
#include <vector>

template<class T>
struct span
{
public:
    using element_type = T;
    using pointer = T*;
    using reference = T&;
    using iterator = T*;

    constexpr span() noexcept : m_ptr(nullptr), m_count(0) {}
    constexpr span(std::nullptr_t) noexcept : span() {}
    constexpr span(T* ptr, size_t count) noexcept : m_ptr(ptr), m_count(count) {}
    constexpr span(T* ptr_begin, T* ptr_end) noexcept : m_ptr(ptr_begin), m_count(ptr_end - ptr_begin) {}

    template<size_t N>
    constexpr span(T (&arr)[N]) noexcept : span(arr, N)
    {
    }

    span(std::vector<T>& v) noexcept : span(v.data(), v.size()) {}
    span(const std::vector<std::remove_const_t<T>>& v) noexcept : span(v.data(), v.size()) {}

    constexpr iterator begin() const { return m_ptr; }
    constexpr iterator end() const { return m_ptr + m_count; }

    constexpr reference operator[](size_t i) const { return m_ptr[i]; }
    constexpr size_t size() const { return m_count; }

private:
    pointer m_ptr;
    size_t m_count;
};
