#pragma once

#include <vcpkg/base/checks.h>

namespace vcpkg
{
    struct NullOpt
    {
        explicit constexpr NullOpt(int) {}
    };

    const static constexpr NullOpt nullopt{0};

    namespace details
    {
        template<class T, bool = std::is_trivially_destructible<T>::value>
        struct OptionalStorage;

        template<class T>
        struct OptionalStorage<T, true>
        {
            constexpr OptionalStorage() noexcept : m_is_present(false), m_ch() {}
            constexpr OptionalStorage(const T& t) : m_is_present(true), m_t(t) {}
            constexpr OptionalStorage(T&& t) : m_is_present(true), m_t(std::move(t)) {}

            constexpr bool has_value() const { return m_is_present; }

            constexpr const T& value() const { return this->m_t; }
            T& value() { return this->m_t; }

        private:
            bool m_is_present;
            union {
                char m_ch;
                T m_t;
            };
        };

        template<class T>
        struct OptionalStorage<T, false>
        {
            constexpr OptionalStorage() noexcept : m_is_present(false), m_ch() {}

            OptionalStorage(const OptionalStorage& o) : m_is_present(o.m_is_present), m_ch()
            {
                if (m_is_present) new (&m_t) T(o.m_t);
            }
            OptionalStorage(OptionalStorage&& o) noexcept : m_is_present(o.m_is_present), m_ch()
            {
                if (m_is_present) new (&m_t) T(std::move(o.m_t));
            }

            constexpr OptionalStorage(const T& t) : m_is_present(true), m_t(t) {}
            constexpr OptionalStorage(T&& t) : m_is_present(true), m_t(std::move(t)) {}

            OptionalStorage& operator=(OptionalStorage const& o)
            {
                if (m_is_present)
                {
                    if (o.m_is_present)
                    {
                        m_t = o.m_t;
                    }
                    else
                    {
                        reset();
                    }
                }
                else if (o.m_is_present)
                {
                    new (&m_t) T(o.m_t);
                    m_is_present = true;
                }

                return *this;
            }
            OptionalStorage& operator=(OptionalStorage&& o) noexcept
            {
                if (m_is_present)
                {
                    if (o.m_is_present)
                    {
                        m_t = std::move(o.m_t);
                    }
                    else
                    {
                        reset();
                    }
                }
                else if (o.m_is_present)
                {
                    new (&m_t) T(std::move(o.m_t));
                    m_is_present = true;
                }

                return *this;
            }

            ~OptionalStorage()
            {
                if (m_is_present) m_t.~T();
            }

            constexpr bool has_value() const { return m_is_present; }

            constexpr const T& value() const { return m_t; }
            T& value() { return m_t; }

        private:
            void reset()
            {
                if (m_is_present) m_t.~T();
                m_is_present = false;
            }

            bool m_is_present;
            union {
                char m_ch;
                T m_t;
            };
        };

        template<class T>
        struct OptionalStorage<T&, true>
        {
            constexpr OptionalStorage() noexcept : m_t(nullptr) {}
            constexpr OptionalStorage(T& t) : m_t(&t) {}
            constexpr bool has_value() const { return m_t != nullptr; }
            constexpr T& value() const { return *this->m_t; }

        private:
            T* m_t;
        };
    }

    template<class T>
    struct Optional : private details::OptionalStorage<T>
    {
        constexpr Optional() noexcept {}
        constexpr Optional(NullOpt) {}

        using details::OptionalStorage<T>::OptionalStorage;

        T&& value_or_exit(const LineInfo& line_info) &&
        {
            exit_if_null(line_info);
            return std::move(details::OptionalStorage<T>::value());
        }

        T& value_or_exit(const LineInfo& line_info) &
        {
            this->exit_if_null(line_info);
            return details::OptionalStorage<T>::value();
        }

        const T& value_or_exit(const LineInfo& line_info) const&
        {
            exit_if_null(line_info);
            return details::OptionalStorage<T>::value();
        }

        constexpr explicit operator bool() const { return details::OptionalStorage<T>::has_value(); }

        constexpr bool has_value() const { return details::OptionalStorage<T>::has_value(); }

        template<class U>
        T value_or(U&& default_value) const&
        {
            return details::OptionalStorage<T>::has_value() ? details::OptionalStorage<T>::value()
                                                            : static_cast<T>(std::forward<U>(default_value));
        }

        template<class U>
        T value_or(U&& default_value) &&
        {
            return details::OptionalStorage<T>::has_value() ? std::move(details::OptionalStorage<T>::value())
                                                            : static_cast<T>(std::forward<U>(default_value));
        }

        typename std::add_pointer<const T>::type get() const
        {
            return details::OptionalStorage<T>::has_value() ? &details::OptionalStorage<T>::value() : nullptr;
        }

        typename std::add_pointer<T>::type get()
        {
            return details::OptionalStorage<T>::has_value() ? &details::OptionalStorage<T>::value() : nullptr;
        }

    private:
        void exit_if_null(const LineInfo& line_info) const
        {
            Checks::check_exit(line_info, details::OptionalStorage<T>::has_value(), "Value was null");
        }
    };

    template<class U>
    Optional<std::decay_t<U>> make_optional(U&& u)
    {
        return Optional<std::decay_t<U>>(std::forward<U>(u));
    }

    template<class T>
    bool operator==(const Optional<T>& o, const T& t)
    {
        if (auto p = o.get()) return *p == t;
        return false;
    }
    template<class T>
    bool operator==(const T& t, const Optional<T>& o)
    {
        if (auto p = o.get()) return t == *p;
        return false;
    }
    template<class T>
    bool operator!=(const Optional<T>& o, const T& t)
    {
        if (auto p = o.get()) return *p != t;
        return true;
    }
    template<class T>
    bool operator!=(const T& t, const Optional<T>& o)
    {
        if (auto p = o.get()) return t != *p;
        return true;
    }
}
