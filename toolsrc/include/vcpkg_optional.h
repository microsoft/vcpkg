#pragma once
#include "LineInfo.h"
#include "vcpkg_Checks.h"

namespace vcpkg
{
    struct NullOpt
    {
        explicit constexpr NullOpt(int) {}
    };

    const static constexpr NullOpt nullopt{ 0 };

    template <class T>
    class Optional
    {
    public:
        constexpr Optional() : m_is_present(false), m_t() { }

        // Constructors are intentionally implicit
        constexpr Optional(NullOpt) : m_is_present(false), m_t() { }

        Optional(const T& t) : m_is_present(true), m_t(t) { }

        Optional(T&& t) : m_is_present(true), m_t(std::move(t)) { }

        T&& value_or_exit(const LineInfo& line_info) &&
        {
            this->exit_if_null(line_info);
            return std::move(this->m_t);
        }

        const T& value_or_exit(const LineInfo& line_info) const &
        {
            this->exit_if_null(line_info);
            return this->m_t;
        }

        constexpr explicit operator bool() const
        {
            return this->m_is_present;
        }

        constexpr bool has_value() const
        {
            return m_is_present;
        }

        template <class U>
        T value_or(U&& default_value) const &
        {
            return bool(*this) ? this->m_t : static_cast<T>(std::forward<U>(default_value));
        }

        template <class U>
        T value_or(U&& default_value) &&
        {
            return bool(*this) ? std::move(this->m_t) : static_cast<T>(std::forward<U>(default_value));
        }

        const T* get() const
        {
            return bool(*this) ? &this->m_t : nullptr;
        }

        T* get()
        {
            return bool(*this) ? &this->m_t : nullptr;
        }

    private:
        void exit_if_null(const LineInfo& line_info) const
        {
            Checks::check_exit(line_info, this->m_is_present, "Value was null");
        }

        bool m_is_present;
        T m_t;
    };
}
