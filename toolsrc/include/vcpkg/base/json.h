#pragma once

#include <vcpkg/base/expected.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/parse.h>
#include <vcpkg/base/stringview.h>

#include <functional>
#include <stddef.h>
#include <stdint.h>
#include <string>
#include <utility>
#include <vector>

namespace vcpkg::Json
{
    struct JsonStyle
    {
        enum class Newline
        {
            Lf,
            CrLf
        } newline_kind = Newline::Lf;

        constexpr JsonStyle() noexcept = default;

        static JsonStyle with_tabs() noexcept { return JsonStyle{-1}; }
        static JsonStyle with_spaces(int indent) noexcept
        {
            vcpkg::Checks::check_exit(VCPKG_LINE_INFO, indent >= 0);
            return JsonStyle{indent};
        }

        void set_tabs() noexcept { this->indent = -1; }
        void set_spaces(int indent_) noexcept
        {
            vcpkg::Checks::check_exit(VCPKG_LINE_INFO, indent >= 0);
            this->indent = indent_;
        }

        bool use_tabs() const noexcept { return indent == -1; }
        bool use_spaces() const noexcept { return indent >= 0; }

        int spaces() const noexcept
        {
            vcpkg::Checks::check_exit(VCPKG_LINE_INFO, indent >= 0);
            return indent;
        }

        const char* newline() const noexcept
        {
            switch (this->newline_kind)
            {
                case Newline::Lf: return "\n";
                case Newline::CrLf: return "\r\n";
                default: Checks::exit_fail(VCPKG_LINE_INFO);
            }
        }

    private:
        constexpr explicit JsonStyle(int indent) : indent(indent) { }
        // -1 for tab, >=0 gives # of spaces
        int indent = 2;
    };

    struct Array;
    struct Object;

    enum class ValueKind
    {
        Null,
        Boolean,
        Number,
        String,
        Array,
        Object
    };

    namespace impl
    {
        struct ValueImpl;
        struct SyntaxErrorImpl;
    }

    struct Value
    {
        ValueKind kind() const noexcept;

        bool is_null() const noexcept;
        bool is_boolean() const noexcept;
        bool is_number() const noexcept;
        bool is_string() const noexcept;
        bool is_array() const noexcept;
        bool is_object() const noexcept;

        // a.x() asserts when !a.is_x()
        bool boolean() const noexcept;
        int64_t number() const noexcept;
        StringView string() const noexcept;

        const Array& array() const noexcept;
        Array& array() noexcept;

        const Object& object() const noexcept;
        Object& object() noexcept;

        Value(Value&&) noexcept;
        Value& operator=(Value&&) noexcept;
        ~Value();

        Value() noexcept; // equivalent to Value::null()
        static Value null(std::nullptr_t) noexcept;
        static Value boolean(bool) noexcept;
        static Value number(int64_t i) noexcept;
        static Value string(StringView) noexcept;
        static Value array(Array&&) noexcept;
        static Value object(Object&&) noexcept;
        Value clone() const noexcept;

    private:
        friend struct impl::ValueImpl;
        std::unique_ptr<impl::ValueImpl> underlying_;
    };

    struct Array
    {
    private:
        using underlying_t = std::vector<Value>;

    public:
        using iterator = underlying_t::iterator;
        using const_iterator = underlying_t::const_iterator;

        void push_back(Value&& value) { this->underlying_.push_back(std::move(value)); }
        void insert_before(iterator it, Value&& value) { this->underlying_.insert(it, std::move(value)); }

        std::size_t size() const noexcept { return this->underlying_.size(); }

        // asserts idx < size
        Value& operator[](std::size_t idx) noexcept
        {
            vcpkg::Checks::check_exit(VCPKG_LINE_INFO, idx < this->size());
            return this->underlying_[idx];
        }
        const Value& operator[](std::size_t idx) const noexcept
        {
            vcpkg::Checks::check_exit(VCPKG_LINE_INFO, idx < this->size());
            return this->underlying_[idx];
        }

        void sort(const std::function<bool(const Value&, const Value&)>& lt)
        {
            std::sort(this->begin(), this->end(), std::ref(lt));
        }

        Array clone() const noexcept;

        iterator begin() { return underlying_.begin(); }
        iterator end() { return underlying_.end(); }
        const_iterator begin() const { return cbegin(); }
        const_iterator end() const { return cend(); }
        const_iterator cbegin() const { return underlying_.cbegin(); }
        const_iterator cend() const { return underlying_.cend(); }

    private:
        underlying_t underlying_;
    };

    struct Object
    {
    private:
        using underlying_t = std::vector<std::pair<std::string, Value>>;

        underlying_t::const_iterator internal_find_key(StringView key) const noexcept;

    public:
        // asserts if the key is found
        void insert(std::string key, Value value) noexcept;

        // replaces the value if the key is found, otherwise inserts a new
        // value.
        void insert_or_replace(std::string key, Value value) noexcept;

        // returns whether the key existed
        bool remove(StringView key) noexcept;

        // asserts on lookup failure
        Value& operator[](StringView key) noexcept
        {
            auto res = this->get(key);
            vcpkg::Checks::check_exit(VCPKG_LINE_INFO, res);
            return *res;
        }
        const Value& operator[](StringView key) const noexcept
        {
            auto res = this->get(key);
            vcpkg::Checks::check_exit(VCPKG_LINE_INFO, res);
            return *res;
        }

        Value* get(StringView key) noexcept;
        const Value* get(StringView key) const noexcept;

        bool contains(StringView key) const noexcept { return this->get(key); }

        std::size_t size() const noexcept { return this->underlying_.size(); }

        void sort_keys(const std::function<bool(StringView, StringView)>& lt) noexcept;

        Object clone() const noexcept;

        struct const_iterator
        {
            using value_type = std::pair<StringView, const Value&>;
            using reference = value_type;
            using iterator_category = std::forward_iterator_tag;

            value_type operator*() const noexcept { return *underlying_; }
            const_iterator& operator++() noexcept
            {
                ++underlying_;
                return *this;
            }
            const_iterator operator++(int) noexcept
            {
                auto res = *this;
                ++underlying_;
                return res;
            }

            bool operator==(const_iterator other) const noexcept { return this->underlying_ == other.underlying_; }
            bool operator!=(const_iterator other) const noexcept { return !(this->underlying_ == other.underlying_); }

        private:
            friend struct Object;
            explicit const_iterator(const underlying_t::const_iterator& it) : underlying_(it) { }
            underlying_t::const_iterator underlying_;
        };
        using iterator = const_iterator;

        const_iterator begin() const noexcept { return this->cbegin(); }
        const_iterator end() const noexcept { return this->cend(); }
        const_iterator cbegin() const noexcept { return const_iterator{this->underlying_.begin()}; }
        const_iterator cend() const noexcept { return const_iterator{this->underlying_.end()}; }

    private:
        underlying_t underlying_;
    };

    // currently, a hard assertion on file errors
    ExpectedT<std::pair<Value, JsonStyle>, std::unique_ptr<Parse::IParseError>> parse_file(
        const Files::Filesystem&, const fs::path&, std::error_code& ec) noexcept;
    ExpectedT<std::pair<Value, JsonStyle>, std::unique_ptr<Parse::IParseError>> parse(
        StringView text, const fs::path& filepath = "") noexcept;
    std::string stringify(const Value&, JsonStyle style) noexcept;

}
