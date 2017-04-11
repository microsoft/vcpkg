#pragma once

#include <system_error>
#include "vcpkg_Checks.h"

namespace vcpkg
{
    template <class T>
    class Expected
    {
    public:
        // Constructors are intentionally implicit
        Expected(const std::error_code& ec) : m_error_code(ec), m_t()
        {
        }

        Expected(std::errc ec) : Expected(std::make_error_code(ec))
        {
        }

        Expected(const T& t) : m_error_code(), m_t(t)
        {
        }

        Expected(T&& t) : m_error_code(), m_t(std::move(t))
        {
        }

        Expected() : Expected(std::error_code(), T())
        {
        }

        Expected(const Expected&) = default;
        Expected(Expected&&) = default;
        Expected& operator=(const Expected&) = default;
        Expected& operator=(Expected&&) = default;

        std::error_code error_code() const
        {
            return this->m_error_code;
        }

        T&& value_or_exit(const LineInfo& line_info) &&
        {
            exit_if_error(line_info);
            return std::move(this->m_t);
        }

        const T& value_or_exit(const LineInfo& line_info) const &
        {
            exit_if_error(line_info);
            return this->m_t;
        }

        const T* get() const
        {
            if (m_error_code)
            {
                return nullptr;
            }
            return &this->m_t;
        }

        T* get()
        {
            if (m_error_code)
            {
                return nullptr;
            }
            return &this->m_t;
        }

    private:
        void exit_if_error(const LineInfo& line_info) const
        {
            Checks::check_exit(line_info, !this->m_error_code, this->m_error_code.message());
        }

        std::error_code m_error_code;
        T m_t;
    };
}
