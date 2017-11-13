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
        template<class T>
        struct OptionalStorage
        {
            constexpr OptionalStorage() : m_is_present(false), m_t() {}
            constexpr OptionalStorage(const T& t) : m_is_present(true), m_t(t) {}
            constexpr OptionalStorage(T&& t) : m_is_present(true), m_t(std::move(t)) {}

            constexpr bool has_value() const { return m_is_present; }

            const T& value() const { return this->m_t; }
            T& value() { return this->m_t; }

        private:
            bool m_is_present;
            T m_t;
        };

        template<class T>
        struct OptionalStorage<T&>
        {
            constexpr OptionalStorage() : m_t(nullptr) {}
            constexpr OptionalStorage(T& t) : m_t(&t) {}

            constexpr bool has_value() const { return m_t != nullptr; }

            T& value() const { return *this->m_t; }

        private:
            T* m_t;
        };
    }

    template<class T>
    struct Optional
    {
        constexpr Optional() {}

        // Constructors are intentionally implicit
        constexpr Optional(NullOpt) {}

        Optional(const T& t) : m_base(t) {}

        template<class = std::enable_if_t<!std::is_reference<T>::value>>
        Optional(T&& t) : m_base(std::move(t))
        {
        }

        T&& value_or_exit(const LineInfo& line_info) &&
        {
            this->exit_if_null(line_info);
            return std::move(this->m_base.value());
        }

        const T& value_or_exit(const LineInfo& line_info) const&
        {
            this->exit_if_null(line_info);
            return this->m_base.value();
        }

        constexpr explicit operator bool() const { return this->m_base.has_value(); }

        constexpr bool has_value() const { return this->m_base.has_value(); }

        template<class U>
        T value_or(U&& default_value) const&
        {
            return this->m_base.has_value() ? this->m_base.value() : static_cast<T>(std::forward<U>(default_value));
        }

        template<class U>
        T value_or(U&& default_value) &&
        {
            return this->m_base.has_value() ? std::move(this->m_base.value())
                                            : static_cast<T>(std::forward<U>(default_value));
        }

        typename std::add_pointer<const T>::type get() const
        {
            return this->m_base.has_value() ? &this->m_base.value() : nullptr;
        }

        typename std::add_pointer<T>::type get() { return this->m_base.has_value() ? &this->m_base.value() : nullptr; }

    private:
        void exit_if_null(const LineInfo& line_info) const
        {
            Checks::check_exit(line_info, this->m_base.has_value(), "Value was null");
        }

        details::OptionalStorage<T> m_base;
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
