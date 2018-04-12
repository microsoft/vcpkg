#pragma once

#include <vcpkg/base/checks.h>

#include <system_error>

namespace vcpkg
{
    namespace details
    {
        struct left_tag_t
        {
        };
        static constexpr left_tag_t left_tag{};
        struct right_tag_t
        {
        };
        static constexpr right_tag_t right_tag{};

        template<class T, class U>
        struct ExpectedStorage
        {
            ExpectedStorage(const ExpectedStorage& o) noexcept : m_has_error(o.m_has_error), m_ch()
            {
                if (o.m_has_error)
                    new (&m_error) U(o.m_error);
                else
                    new (&m_t) T(o.m_t);
            }
            ExpectedStorage(ExpectedStorage&& o) noexcept : m_has_error(o.m_has_error), m_ch()
            {
                if (o.m_has_error)
                    new (&m_error) U(std::move(o.m_error));
                else
                {
                    new (&m_t) T(std::move(o.m_t));
                }
            }
            constexpr ExpectedStorage(T&& t, left_tag_t = left_tag) : m_has_error(false), m_t(std::move(t)) {}
            constexpr ExpectedStorage(U&& u, right_tag_t = right_tag) : m_has_error(true), m_error(std::move(u)) {}

            ExpectedStorage& operator=(const ExpectedStorage& o) noexcept
            {
                if (o.m_has_error)
                {
                    if (m_has_error)
                        m_error = o.m_error;
                    else
                    {
                        m_t.~T();
                        new (&m_error) U(o.m_error);
                        m_has_error = true;
                    }
                }
                else if (m_has_error)
                {
                    m_error.~U();
                    new (&m_t) T(o.m_t);
                    m_has_error = false;
                }
                else
                    m_t = o.m_t;

                return *this;
            }

            ExpectedStorage& operator=(ExpectedStorage&& o) noexcept
            {
                if (o.m_has_error)
                {
                    if (m_has_error)
                        m_error = std::move(o.m_error);
                    else
                    {
                        m_t.~T();
                        new (&m_error) U(std::move(o.m_error));
                        m_has_error = true;
                    }
                }
                else if (m_has_error)
                {
                    m_error.~U();
                    new (&m_t) T(std::move(o.m_t));
                    m_has_error = false;
                }
                else
                    m_t = std::move(o.m_t);

                return *this;
            }

            ~ExpectedStorage()
            {
                if (m_has_error)
                    m_error.~U();
                else
                    m_t.~T();
            }

            constexpr bool has_error() const { return m_has_error; }

            constexpr const U& error() const { return m_error; }
            U& error() { return m_error; }

            constexpr const T& value() const { return m_t; }
            T& value() { return m_t; }

        private:
            bool m_has_error;
            union {
                char m_ch;
                T m_t;
                U m_error;
            };
        };

        inline void exit_with_generic_message(const LineInfo& line_info, const std::error_code& ec)
        {
            Checks::exit_with_message(line_info, "Failed at [%s] with message:\n%s", line_info, ec.message());
        }
        template<class T>
        void exit_with_generic_message(const LineInfo& line_info, const T&)
        {
            Checks::exit_with_message(line_info, "Failed at [%s]. Expected<T> held an error value.", line_info);
        }
    }

    template<class T, class E>
    class ExpectedT
    {
    public:
        ExpectedT(const ExpectedT&) = default;
        ExpectedT(ExpectedT&&) = default;
        ExpectedT& operator=(const ExpectedT&) = default;
        ExpectedT& operator=(ExpectedT&&) = default;

        template<class U>
        ExpectedT(U&& u) : m_storage(std::forward<U>(u))
        {
        }

        template<class U, class Tag>
        ExpectedT(U&& u, Tag) : m_storage(std::forward<U>(u), Tag{})
        {
        }

        explicit constexpr operator bool() const noexcept { return !m_storage.has_error(); }
        constexpr bool has_value() const noexcept { return !m_storage.has_error(); }
        constexpr bool has_error() const noexcept { return m_storage.has_error(); }

        T&& value_or_exit(const LineInfo& line_info) &&
        {
            exit_if_error(line_info);
            return std::move(m_storage.value());
        }

        const T& value_or_exit(const LineInfo& line_info) const&
        {
            exit_if_error(line_info);
            return m_storage.value();
        }

        const E* get_error() const
        {
            if (m_storage.has_error())
                return &m_storage.error();
            else
                return nullptr;
        }
        E* get_error()
        {
            if (m_storage.has_error())
                return &m_storage.error();
            else
                return nullptr;
        }

        const T* get() const
        {
            if (m_storage.has_error())
                return nullptr;
            else
                return &m_storage.value();
        }

        T* get()
        {
            if (m_storage.has_error())
                return nullptr;
            else
                return &m_storage.value();
        }

    private:
        void exit_if_error(const LineInfo& line_info) const
        {
            // This is used for quick value_or_exit() calls, so always put line_info in the error message.
            if (m_storage.has_error())
            {
                details::exit_with_generic_message(line_info, m_storage.error());
            }
        }

        details::ExpectedStorage<T, E> m_storage;
    };

    template<class T>
    using Expected = ExpectedT<T, std::error_code>;

    namespace Util
    {
        template<class T, class Func>
        using FmapExpectedOut = decltype(std::declval<Func&>()(std::declval<T&>()));

        template<class T, class E, class F>
        ExpectedT<FmapExpectedOut<T, F>, E> fmap(ExpectedT<T, E>&& e, F map_left)
        {
            if (auto err = e.get_error())
                return std::move(*err);
            else
                return map_left(*e.get());
        }
    }
}
