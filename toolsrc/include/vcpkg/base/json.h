#pragma once

#include <vcpkg/base/expected.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/parse.h>
#include <vcpkg/base/stringview.h>

#include <stddef.h>
#include <stdint.h>

#include <memory>
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
        Integer,
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
        Value() noexcept; // equivalent to Value::null()
        Value(Value&&) noexcept;
        Value(const Value&);
        Value& operator=(Value&&) noexcept;
        Value& operator=(const Value&);
        ~Value();

        ValueKind kind() const noexcept;

        bool is_null() const noexcept;
        bool is_boolean() const noexcept;
        bool is_integer() const noexcept;
        // either integer _or_ number
        bool is_number() const noexcept;
        bool is_string() const noexcept;
        bool is_array() const noexcept;
        bool is_object() const noexcept;

        // a.x() asserts when !a.is_x()
        bool boolean() const noexcept;
        int64_t integer() const noexcept;
        double number() const noexcept;
        StringView string() const noexcept;

        const Array& array() const& noexcept;
        Array& array() & noexcept;
        Array&& array() && noexcept;

        const Object& object() const& noexcept;
        Object& object() & noexcept;
        Object&& object() && noexcept;

        static Value null(std::nullptr_t) noexcept;
        static Value boolean(bool) noexcept;
        static Value integer(int64_t i) noexcept;
        static Value number(double d) noexcept;
        static Value string(StringView) noexcept;
        static Value array(Array&&) noexcept;
        static Value array(const Array&) noexcept;
        static Value object(Object&&) noexcept;
        static Value object(const Object&) noexcept;

        friend bool operator==(const Value& lhs, const Value& rhs);
        friend bool operator!=(const Value& lhs, const Value& rhs) { return !(lhs == rhs); }

    private:
        friend struct impl::ValueImpl;
        std::unique_ptr<impl::ValueImpl> underlying_;
    };

    struct Array
    {
    private:
        using underlying_t = std::vector<Value>;

    public:
        Array() = default;
        Array(Array const&) = default;
        Array(Array&&) = default;
        Array& operator=(Array const&) = default;
        Array& operator=(Array&&) = default;
        ~Array() = default;

        using iterator = underlying_t::iterator;
        using const_iterator = underlying_t::const_iterator;

        Value& push_back(Value&& value);
        Object& push_back(Object&& value);
        Array& push_back(Array&& value);
        Value& insert_before(iterator it, Value&& value);
        Object& insert_before(iterator it, Object&& value);
        Array& insert_before(iterator it, Array&& value);

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

        iterator begin() { return underlying_.begin(); }
        iterator end() { return underlying_.end(); }
        const_iterator begin() const { return cbegin(); }
        const_iterator end() const { return cend(); }
        const_iterator cbegin() const { return underlying_.cbegin(); }
        const_iterator cend() const { return underlying_.cend(); }

        friend bool operator==(const Array& lhs, const Array& rhs);
        friend bool operator!=(const Array& lhs, const Array& rhs) { return !(lhs == rhs); }

    private:
        underlying_t underlying_;
    };
    struct Object
    {
    private:
        using value_type = std::pair<std::string, Value>;
        using underlying_t = std::vector<value_type>;

        underlying_t::const_iterator internal_find_key(StringView key) const noexcept;

    public:
        // these are here for better diagnostics
        Object() = default;
        Object(Object const&) = default;
        Object(Object&&) = default;
        Object& operator=(Object const&) = default;
        Object& operator=(Object&&) = default;
        ~Object() = default;

        // asserts if the key is found
        Value& insert(std::string key, Value&& value);
        Value& insert(std::string key, const Value& value);
        Object& insert(std::string key, Object&& value);
        Object& insert(std::string key, const Object& value);
        Array& insert(std::string key, Array&& value);
        Array& insert(std::string key, const Array& value);

        // replaces the value if the key is found, otherwise inserts a new
        // value.
        Value& insert_or_replace(std::string key, Value&& value);
        Value& insert_or_replace(std::string key, const Value& value);
        Object& insert_or_replace(std::string key, Object&& value);
        Object& insert_or_replace(std::string key, const Object& value);
        Array& insert_or_replace(std::string key, Array&& value);
        Array& insert_or_replace(std::string key, const Array& value);

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

        bool is_empty() const noexcept { return size() == 0; }
        std::size_t size() const noexcept { return this->underlying_.size(); }

        // sorts keys alphabetically
        void sort_keys();

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

        friend bool operator==(const Object& lhs, const Object& rhs);
        friend bool operator!=(const Object& lhs, const Object& rhs) { return !(lhs == rhs); }

    private:
        underlying_t underlying_;
    };

    struct ReaderError
    {
        virtual void add_missing_field(std::string&& type, std::string&& key) = 0;
        virtual void add_expected_type(std::string&& key, std::string&& expected_type) = 0;
        virtual void add_extra_fields(std::string&& type, std::vector<std::string>&& fields) = 0;
        virtual void add_mutually_exclusive_fields(std::string&& type, std::vector<std::string>&& fields) = 0;

        virtual ~ReaderError() = default;
    };

    struct Reader
    {
        explicit Reader(ReaderError* err) : err(err) { }

        ReaderError& error() const { return *err; }

    private:
        ReaderError* err;

        template<class Visitor>
        using VisitorType = typename std::remove_reference_t<Visitor>::type;

        template<class Visitor>
        Optional<VisitorType<Visitor>> internal_visit(const Value& value, StringView key, Visitor& visitor)
        {
            switch (value.kind())
            {
                using VK = Json::ValueKind;
                case VK::Null: return visitor.visit_null(*this, key);
                case VK::Boolean: return visitor.visit_boolean(*this, key, value.boolean());
                case VK::Integer: return visitor.visit_integer(*this, key, value.integer());
                case VK::Number: return visitor.visit_number(*this, key, value.number());
                case VK::String: return visitor.visit_string(*this, key, value.string());
                case VK::Array: return visitor.visit_array(*this, key, value.array());
                case VK::Object: return visitor.visit_object(*this, key, value.object());
            }

            vcpkg::Checks::exit_fail(VCPKG_LINE_INFO);
        }

        // returns whether the field was found, not whether it was valid
        template<class Visitor>
        bool internal_field(const Object& obj, StringView key, VisitorType<Visitor>& place, Visitor& visitor)
        {
            auto value = obj.get(key);
            if (!value)
            {
                return false;
            }

            Optional<VisitorType<Visitor>> opt = internal_visit(*value, key, visitor);

            if (auto val = opt.get())
            {
                place = std::move(*val);
            }
            else
            {
                err->add_expected_type(key.to_string(), visitor.type_name().to_string());
            }

            return true;
        }

    public:
        template<class Visitor>
        void required_object_field(
            StringView type, const Object& obj, StringView key, VisitorType<Visitor>& place, Visitor&& visitor)
        {
            if (!internal_field(obj, key, place, visitor))
            {
                err->add_missing_field(type.to_string(), key.to_string());
            }
        }

        template<class Visitor>
        void optional_object_field(const Object& obj, StringView key, VisitorType<Visitor>& place, Visitor&& visitor)
        {
            internal_field(obj, key, place, visitor);
        }

        template<class Visitor>
        Optional<std::vector<VisitorType<Visitor>>> array_elements(const Array& arr, StringView key, Visitor&& visitor)
        {
            std::vector<VisitorType<Visitor>> result;
            for (const auto& el : arr)
            {
                auto opt = internal_visit(el, key, visitor);
                if (auto p = opt.get())
                {
                    result.push_back(std::move(*p));
                }
                else
                {
                    return nullopt;
                }
            }
            return std::move(result);
        }
    };

    // Warning: NEVER use this type except as a CRTP base
    template<class Underlying>
    struct VisitorCrtpBase
    {
        // the following function must be defined by the Underlying class
        // const char* type_name();

        // We do this auto dance since function bodies are checked _after_ typedefs in the superclass,
        // but function declarations are checked beforehand. Therefore, we can get C++ to use this typedef
        // only once the function bodies are checked by returning `auto` and specifying the
        // return type in the function body.
        auto visit_null(Reader&, StringView) { return Optional<typename Underlying::type>(nullopt); }
        auto visit_boolean(Reader&, StringView, bool) { return Optional<typename Underlying::type>(nullopt); }
        auto visit_integer(Reader& r, StringView field_name, int64_t i)
        {
            return static_cast<Underlying&>(*this).visit_number(r, field_name, static_cast<double>(i));
        }
        auto visit_number(Reader&, StringView, double) { return Optional<typename Underlying::type>(nullopt); }
        auto visit_string(Reader&, StringView, StringView) { return Optional<typename Underlying::type>(nullopt); }
        auto visit_array(Reader&, StringView, const Json::Array&)
        {
            return Optional<typename Underlying::type>(nullopt);
        }
        auto visit_object(Reader&, StringView, const Json::Object&)
        {
            return Optional<typename Underlying::type>(nullopt);
        }
        // we can't make the SMFs protected because of an issue with /permissive mode
    };

    ExpectedT<std::pair<Value, JsonStyle>, std::unique_ptr<Parse::IParseError>> parse_file(
        const Files::Filesystem&, const fs::path&, std::error_code& ec) noexcept;
    ExpectedT<std::pair<Value, JsonStyle>, std::unique_ptr<Parse::IParseError>> parse(
        StringView text, const fs::path& filepath = {}) noexcept;

    std::string stringify(const Value&, JsonStyle style);
    std::string stringify(const Object&, JsonStyle style);
    std::string stringify(const Array&, JsonStyle style);

}
