#pragma once

#include <vcpkg/base/optional.h>

#include <limits>
#include <string>
#include <vector>

namespace vcpkg
{
    struct StringView
    {
        static std::vector<StringView> find_all_enclosed(const StringView& input,
                                                         const std::string& left_delim,
                                                         const std::string& right_delim);

        static StringView find_exactly_one_enclosed(const StringView& input,
                                                    const std::string& left_tag,
                                                    const std::string& right_tag);

        static Optional<StringView> find_at_most_one_enclosed(const StringView& input,
                                                              const std::string& left_tag,
                                                              const std::string& right_tag);

        constexpr StringView() = default;
        StringView(const std::string& s); // Implicit by design

        // NOTE: we do this instead of the delegating constructor since delegating ctors are a perf footgun
        template<size_t Sz>
        constexpr StringView(const char (&arr)[Sz]) : m_ptr(arr), m_size(Sz - 1)
        {
        }

        constexpr StringView(const char* ptr, size_t size) : m_ptr(ptr), m_size(size) { }
        constexpr StringView(const char* b, const char* e) : m_ptr(b), m_size(static_cast<size_t>(e - b)) { }

        constexpr const char* begin() const { return m_ptr; }
        constexpr const char* end() const { return m_ptr + m_size; }

        std::reverse_iterator<const char*> rbegin() const { return std::make_reverse_iterator(end()); }
        std::reverse_iterator<const char*> rend() const { return std::make_reverse_iterator(begin()); }

        constexpr const char* data() const { return m_ptr; }
        constexpr size_t size() const { return m_size; }

        std::string to_string() const;
        void to_string(std::string& out) const;

        StringView substr(size_t pos, size_t count = std::numeric_limits<size_t>::max()) const;

        constexpr char byte_at_index(size_t pos) const { return m_ptr[pos]; }

    private:
        const char* m_ptr = 0;
        size_t m_size = 0;
    };

    bool operator==(StringView lhs, StringView rhs) noexcept;
    bool operator!=(StringView lhs, StringView rhs) noexcept;
    bool operator<(StringView lhs, StringView rhs) noexcept;
    bool operator>(StringView lhs, StringView rhs) noexcept;
    bool operator<=(StringView lhs, StringView rhs) noexcept;
    bool operator>=(StringView lhs, StringView rhs) noexcept;
}
