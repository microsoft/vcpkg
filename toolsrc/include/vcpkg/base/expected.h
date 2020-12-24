#pragma once

#include <vcpkg/base/checks.h>
#include <vcpkg/base/lineinfo.h>
#include <vcpkg/base/stringliteral.h>

#include <system_error>
#include <type_traits>

namespace vcpkg
{
    template<class Err>
    struct ErrorHolder
    {
        ErrorHolder() : m_is_error(false), m_err{} { }
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
        ErrorHolder() : m_is_error(false) { }
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
        ErrorHolder(const std::error_code& err) : m_err(err) { }

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

    template<class T>
    struct ExpectedHolder
    {
        ExpectedHolder() = default;
        ExpectedHolder(const T& t) : t(t) { }
        ExpectedHolder(T&& t) : t(std::move(t)) { }
        using pointer = T*;
        using const_pointer = const T*;
        T* get() { return &t; }
        const T* get() const { return &t; }
        T t;
    };
    template<class T>
    struct ExpectedHolder<T&>
    {
        ExpectedHolder(T& t) : t(&t) { }
        ExpectedHolder() : t(nullptr) { }
        using pointer = T*;
        using const_pointer = T*;
        T* get() { return t; }
        T* get() const { return t; }
        T* t;
    };

    template<class T, class S>
    class ExpectedT
    {
    public:
        constexpr ExpectedT() = default;

        // Constructors are intentionally implicit

        ExpectedT(const S& s, ExpectedRightTag = {}) : m_s(s) { }
        template<class = std::enable_if<!std::is_reference<S>::value>>
        ExpectedT(S&& s, ExpectedRightTag = {}) : m_s(std::move(s))
        {
        }

        ExpectedT(const T& t, ExpectedLeftTag = {}) : m_t(t) { }
        template<class = std::enable_if<!std::is_reference<T>::value>>
        ExpectedT(T&& t, ExpectedLeftTag = {}) : m_t(std::move(t))
        {
        }

        ExpectedT(const ExpectedT&) = default;
        ExpectedT(ExpectedT&&) = default;
        ExpectedT& operator=(const ExpectedT&) = default;
        ExpectedT& operator=(ExpectedT&&) = default;

        explicit constexpr operator bool() const noexcept { return !m_s.has_error(); }
        constexpr bool has_value() const noexcept { return !m_s.has_error(); }

        T&& value_or_exit(const LineInfo& line_info) &&
        {
            exit_if_error(line_info);
            return std::move(*this->m_t.get());
        }

        const T& value_or_exit(const LineInfo& line_info) const&
        {
            exit_if_error(line_info);
            return *this->m_t.get();
        }

        const S& error() const& { return this->m_s.error(); }

        S&& error() && { return std::move(this->m_s.error()); }

        typename ExpectedHolder<T>::const_pointer get() const
        {
            if (!this->has_value())
            {
                return nullptr;
            }
            return this->m_t.get();
        }

        typename ExpectedHolder<T>::pointer get()
        {
            if (!this->has_value())
            {
                return nullptr;
            }
            return this->m_t.get();
        }

        template<class F>
        using map_t = decltype(std::declval<F&>()(*std::declval<typename ExpectedHolder<T>::const_pointer>()));

        template<class F, class U = map_t<F>>
        ExpectedT<U, S> map(F f) const&
        {
            if (has_value())
            {
                return {f(*m_t.get()), expected_left_tag};
            }
            else
            {
                return {error(), expected_right_tag};
            }
        }

        template<class F>
        using move_map_t =
            decltype(std::declval<F&>()(std::move(*std::declval<typename ExpectedHolder<T>::pointer>())));

        template<class F, class U = move_map_t<F>>
        ExpectedT<U, S> map(F f) &&
        {
            if (has_value())
            {
                return {f(std::move(*m_t.get())), expected_left_tag};
            }
            else
            {
                return {std::move(*this).error(), expected_right_tag};
            }
        }

        template<class F, class U = map_t<F>>
        U then(F f) const&
        {
            if (has_value())
            {
                return f(*m_t.get());
            }
            else
            {
                return U{error(), expected_right_tag};
            }
        }

        template<class F, class U = move_map_t<F>>
        U then(F f) &&
        {
            if (has_value())
            {
                return f(std::move(*m_t.get()));
            }
            else
            {
                return U{std::move(*this).error(), expected_right_tag};
            }
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
        ExpectedHolder<T> m_t;
    };

    template<class T>
    using Expected = ExpectedT<T, std::error_code>;

    template<class T>
    using ExpectedS = ExpectedT<T, std::string>;
}
