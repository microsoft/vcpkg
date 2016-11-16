#pragma once

#include <system_error>
#include "vcpkg_Checks.h"

namespace vcpkg
{
    template <class T>
    class expected
    {
    public:
        // Constructors are intentionally implicit 
        expected(const std::error_code& ec) : m_error_code(ec), m_t()
        {
        }

        expected(std::errc ec) : expected(std::make_error_code(ec))
        {
        }

        expected(const T& t) : m_error_code(), m_t(t)
        {
        }

        expected(T&& t) : m_error_code(), m_t(std::move(t))
        {
        }

        expected() : expected(std::error_code(), T())
        {
        }

        expected(const expected&) = default;
        expected(expected&&) = default;
        expected& operator=(const expected&) = default;
        expected& operator=(expected&&) = default;

        std::error_code error_code() const
        {
            return this->m_error_code;
        }

        T&& get_or_throw() &&
        {
            throw_if_error();
            return std::move(this->m_t);
        }

        const T& get_or_throw() const &
        {
            throw_if_error();
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
        void throw_if_error() const
        {
            Checks::check_throw(!this->m_error_code, this->m_error_code.message().c_str());
        }

        std::error_code m_error_code;
        T m_t;
    };
}
