#pragma once

#include <vcpkg/base/checks.h>
#include <vcpkg/base/stringliteral.h>

#include <system_error>

namespace vcpkg
{
    template<class Err>
    struct ErrorHolder
    {
        ErrorHolder() : m_is_error(false) {}
        template<class U>
        ErrorHolder(U&& err) : m_is_error(true), m_err(std::forward<U>(err))
        {
        }

        constexpr bool has_error() const { return m_is_error; }

        const Err& error() const { return m_err; }
        Err& error() { return m_err; }

        StringLiteral to_string() const { return "value was error"; }

    private:
        bool m_is_error;
        Err m_err;
    };

    template<>
    struct ErrorHolder<std::string>
    {
        ErrorHolder() : m_is_error(false) {}
        template<class U>
        ErrorHolder(U&& err) : m_is_error(true), m_err(std::forward<U>(err))
        {
        }

        bool has_error() const { return m_is_error; }

        const std::string& error() const { return m_err; }
        std::string& error() { return m_err; }

        const std::string& to_string() const { return m_err; }

    private:
        bool m_is_error;
        std::string m_err;
    };

    template<>
    struct ErrorHolder<std::error_code>
    {
        ErrorHolder() = default;
        ErrorHolder(const std::error_code& err) : m_err(err) {}

        bool has_error() const { return bool(m_err); }

        const std::error_code& error() const { return m_err; }
        std::error_code& error() { return m_err; }

        std::string to_string() const { return m_err.message(); }

    private:
        std::error_code m_err;
    };

    struct ExpectedLeftTag
    {
    };
    struct ExpectedRightTag
    {
    };
    constexpr ExpectedLeftTag expected_left_tag;
    constexpr ExpectedRightTag expected_right_tag;

    template<class T, class S>
    class ExpectedT
    {
    public:
        constexpr ExpectedT() = default;

        // Constructors are intentionally implicit

        ExpectedT(const S& s, ExpectedRightTag = {}) : m_s(s) {}
        ExpectedT(S&& s, ExpectedRightTag = {}) : m_s(std::move(s)) {}

        ExpectedT(const T& t, ExpectedLeftTag = {}) : m_t(t) {}
        ExpectedT(T&& t, ExpectedLeftTag = {}) : m_t(std::move(t)) {}

        ExpectedT(const ExpectedT&) = default;
        ExpectedT(ExpectedT&&) = default;
        ExpectedT& operator=(const ExpectedT&) = default;
        ExpectedT& operator=(ExpectedT&&) = default;

        explicit constexpr operator bool() const noexcept { return !m_s.has_error(); }
        constexpr bool has_value() const noexcept { return !m_s.has_error(); }

        T&& value_or_exit(const LineInfo& line_info) &&
        {
            exit_if_error(line_info);
            return std::move(this->m_t);
        }

        const T& value_or_exit(const LineInfo& line_info) const&
        {
            exit_if_error(line_info);
            return this->m_t;
        }

        const S& error() const& { return this->m_s.error(); }

        S&& error() && { return std::move(this->m_s.error()); }

        const T* get() const
        {
            if (!this->has_value())
            {
                return nullptr;
            }
            return &this->m_t;
        }

        T* get()
        {
            if (!this->has_value())
            {
                return nullptr;
            }
            return &this->m_t;
        }

    private:
        void exit_if_error(const LineInfo& line_info) const
        {
            // This is used for quick value_or_exit() calls, so always put line_info in the error message.
            Checks::check_exit(line_info,
                               !m_s.has_error(),
                               "Failed at [%s] with message:\n%s",
                               line_info.to_string(),
                               m_s.to_string());
        }

        ErrorHolder<S> m_s;
        T m_t;
    };

    template<class T>
    using Expected = ExpectedT<T, std::error_code>;
}
