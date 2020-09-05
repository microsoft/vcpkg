#pragma once

#include <vcpkg/base/fwd/json.h>

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

    enum class ValueKind : int
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
            vcpkg::Checks::check_exit(VCPKG_LINE_INFO, res, "missing key: \"%s\"", key);
            return *res;
        }
        const Value& operator[](StringView key) const noexcept
        {
            auto res = this->get(key);
            vcpkg::Checks::check_exit(VCPKG_LINE_INFO, res, "missing key: \"%s\"", key);
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

    VCPKG_MSVC_WARNING(push)
    VCPKG_MSVC_WARNING(disable : 4505)

    template<class Type>
    Span<const StringView> IDeserializer<Type>::valid_fields() const
    {
        return {};
    }

    template<class Type>
    Optional<Type> IDeserializer<Type>::visit_null(Reader&, StringView)
    {
        return nullopt;
    }
    template<class Type>
    Optional<Type> IDeserializer<Type>::visit_boolean(Reader&, StringView, bool)
    {
        return nullopt;
    }
    template<class Type>
    Optional<Type> IDeserializer<Type>::visit_integer(Reader& r, StringView field_name, int64_t i)
    {
        return this->visit_number(r, field_name, static_cast<double>(i));
    }
    template<class Type>
    Optional<Type> IDeserializer<Type>::visit_number(Reader&, StringView, double)
    {
        return nullopt;
    }
    template<class Type>
    Optional<Type> IDeserializer<Type>::visit_string(Reader&, StringView, StringView)
    {
        return nullopt;
    }
    template<class Type>
    Optional<Type> IDeserializer<Type>::visit_array(Reader&, StringView, const Array&)
    {
        return nullopt;
    }
    template<class Type>
    Optional<Type> IDeserializer<Type>::visit_object(Reader&, StringView, const Object&)
    {
        return nullopt;
    }

    VCPKG_MSVC_WARNING(pop)

    struct ReaderError
    {
        virtual void add_missing_field(std::string&& type, std::string&& key) = 0;
        virtual void add_expected_type(std::string&& key, std::string&& expected_type) = 0;
        virtual void add_extra_fields(std::string&& type, std::vector<std::string>&& fields) = 0;
        virtual void add_mutually_exclusive_fields(std::string&& type, std::vector<std::string>&& fields) = 0;

        virtual ~ReaderError() = default;
    };

    struct BasicReaderError : ReaderError
    {
        virtual void add_missing_field(std::string&& type, std::string&& key) override
        {
            missing_fields.emplace_back(std::move(type), std::move(key));
        }
        virtual void add_expected_type(std::string&& key, std::string&& expected_type) override
        {
            expected_types.emplace_back(std::move(key), std::move(expected_type));
        }
        virtual void add_extra_fields(std::string&& type, std::vector<std::string>&& fields) override
        {
            extra_fields.emplace_back(std::move(type), std::move(fields));
        }
        virtual void add_mutually_exclusive_fields(std::string&& type, std::vector<std::string>&& fields) override
        {
            mutually_exclusive_fields.emplace_back(std::move(type), std::move(fields));
        }

        bool has_error() const
        {
            return !missing_fields.empty() || !expected_types.empty() || !extra_fields.empty() ||
                   !mutually_exclusive_fields.empty();
        }

        std::vector<std::pair<std::string, std::string>> missing_fields;
        std::vector<std::pair<std::string, std::string>> expected_types;
        std::vector<std::pair<std::string, std::vector<std::string>>> extra_fields;
        std::vector<std::pair<std::string, std::vector<std::string>>> mutually_exclusive_fields;
    };

    struct Reader
    {
        explicit Reader(ReaderError* err) : err(err) { }

        ReaderError& error() const { return *err; }

    private:
        ReaderError* err;

        template<class Type>
        Optional<Type> internal_visit(const Value& value, StringView key, IDeserializer<Type>& visitor)
        {
            switch (value.kind())
            {
                case ValueKind::Null: return visitor.visit_null(*this, key);
                case ValueKind::Boolean: return visitor.visit_boolean(*this, key, value.boolean());
                case ValueKind::Integer: return visitor.visit_integer(*this, key, value.integer());
                case ValueKind::Number: return visitor.visit_number(*this, key, value.number());
                case ValueKind::String: return visitor.visit_string(*this, key, value.string());
                case ValueKind::Array: return visitor.visit_array(*this, key, value.array());
                case ValueKind::Object:
                {
                    const auto& obj = value.object();
                    check_for_unexpected_fields(obj, visitor.valid_fields(), visitor.type_name());
                    return visitor.visit_object(*this, key, value.object());
                }
            }

            vcpkg::Checks::exit_fail(VCPKG_LINE_INFO);
        }

        // returns whether the field was found, not whether it was valid
        template<class Type>
        bool internal_field(const Object& obj, StringView key, Type& place, IDeserializer<Type>& visitor)
        {
            auto value = obj.get(key);
            if (!value)
            {
                return false;
            }

            Optional<Type> opt = internal_visit(*value, key, visitor);

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

        static std::vector<std::string> invalid_json_fields(const Json::Object& obj,
                                                            Span<const StringView> known_fields) noexcept
        {
            const auto field_is_unknown = [known_fields](StringView sv) {
                // allow directives
                if (sv.size() != 0 && *sv.begin() == '$')
                {
                    return false;
                }
                return std::find(known_fields.begin(), known_fields.end(), sv) == known_fields.end();
            };

            std::vector<std::string> res;
            for (const auto& kv : obj)
            {
                if (field_is_unknown(kv.first))
                {
                    res.push_back(kv.first.to_string());
                }
            }

            return res;
        }

        // checks that an object doesn't contain any fields which both:
        // * don't start with a `$`
        // * are not in `valid_fields`
        // if known_fields.empty(), then it's treated as if all field names are valid
        void check_for_unexpected_fields(const Object& obj, Span<const StringView> valid_fields, StringView type_name)
        {
            if (valid_fields.size() == 0)
            {
                return;
            }

            auto extra_fields = invalid_json_fields(obj, valid_fields);
            if (!extra_fields.empty())
            {
                error().add_extra_fields(type_name.to_string(), std::move(extra_fields));
            }
        }

    public:
        template<class Type>
        void required_object_field(
            StringView type, const Object& obj, StringView key, Type& place, IDeserializer<Type>& visitor)
        {
            if (!internal_field(obj, key, place, visitor))
            {
                err->add_missing_field(type.to_string(), key.to_string());
            }
        }
        template<class Type>
        void required_object_field(
            StringView type, const Object& obj, StringView key, Type& place, IDeserializer<Type>&& visitor)
        {
            required_object_field(type, obj, key, place, visitor);
        }

        // returns whether key \in obj
        template<class Type>
        bool optional_object_field(const Object& obj, StringView key, Type& place, IDeserializer<Type>& visitor)
        {
            return internal_field(obj, key, place, visitor);
        }
        template<class Type>
        bool optional_object_field(const Object& obj, StringView key, Type& place, IDeserializer<Type>&& visitor)
        {
            return optional_object_field(obj, key, place, visitor);
        }

        template<class Type>
        Optional<Type> visit_value(const Value& value, StringView key, IDeserializer<Type>& visitor)
        {
            return internal_visit(value, key, visitor);
        }
        template<class Type>
        Optional<Type> visit_value(const Value& value, StringView key, IDeserializer<Type>&& visitor)
        {
            return visit_value(value, key, visitor);
        }

        template<class Type>
        Optional<Type> visit_value(const Array& value, StringView key, IDeserializer<Type>& visitor)
        {
            return visitor.visit_array(*this, key, value);
        }
        template<class Type>
        Optional<Type> visit_value(const Array& value, StringView key, IDeserializer<Type>&& visitor)
        {
            return visit_value(value, key, visitor);
        }

        template<class Type>
        Optional<Type> visit_value(const Object& value, StringView key, IDeserializer<Type>& visitor)
        {
            check_for_unexpected_fields(value, visitor.valid_fields(), visitor.type_name());
            return visitor.visit_object(*this, key, value);
        }
        template<class Type>
        Optional<Type> visit_value(const Object& value, StringView key, IDeserializer<Type>&& visitor)
        {
            return visit_value(value, key, visitor);
        }

        template<class Type>
        Optional<std::vector<Type>> array_elements(const Array& arr, StringView key, IDeserializer<Type>& visitor)
        {
            std::vector<Type> result;
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
        template<class Type>
        Optional<std::vector<Type>> array_elements(const Array& arr, StringView key, IDeserializer<Type>&& visitor)
        {
            return array_elements(arr, key, visitor);
        }
    };

    struct StringDeserializer final : IDeserializer<std::string>
    {
        virtual StringView type_name() const override { return type_name_; }
        virtual Optional<std::string> visit_string(Reader&, StringView, StringView sv) override
        {
            return sv.to_string();
        }

        explicit StringDeserializer(StringView type_name_) : type_name_(type_name_) { }

    private:
        StringView type_name_;
    };

    struct PathDeserializer final : IDeserializer<fs::path>
    {
        virtual StringView type_name() const override { return "a path"; }
        virtual Optional<fs::path> visit_string(Reader&, StringView, StringView sv) override { return fs::u8path(sv); }
    };

    struct NaturalNumberDeserializer final : IDeserializer<int>
    {
        virtual StringView type_name() const override { return "a natural number"; }

        virtual Optional<int> visit_integer(Reader&, StringView, int64_t value) override
        {
            if (value > std::numeric_limits<int>::max() || value < 0)
            {
                return nullopt;
            }
            return static_cast<int>(value);
        }
    };

    struct BooleanDeserializer final : IDeserializer<bool>
    {
        virtual StringView type_name() const override { return "a boolean"; }

        virtual Optional<bool> visit_boolean(Reader&, StringView, bool b) override { return b; }
    };

    enum class AllowEmpty : bool
    {
        No,
        Yes,
    };

    template<class Underlying>
    struct ArrayDeserializer final : IDeserializer<std::vector<typename Underlying::type>>
    {
        using typename IDeserializer<std::vector<typename Underlying::type>>::type;

        virtual StringView type_name() const override { return type_name_; }

        ArrayDeserializer(StringView type_name_, AllowEmpty allow_empty, Underlying&& t = {})
            : type_name_(type_name_), underlying_visitor_(static_cast<Underlying&&>(t)), allow_empty_(allow_empty)
        {
        }

        virtual Optional<type> visit_array(Reader& r, StringView key, const Array& arr) override
        {
            if (allow_empty_ == AllowEmpty::No && arr.size() == 0)
            {
                return nullopt;
            }
            return r.array_elements(arr, key, underlying_visitor_);
        }

    private:
        StringView type_name_;
        Underlying underlying_visitor_;
        AllowEmpty allow_empty_;
    };

    struct ParagraphDeserializer final : IDeserializer<std::vector<std::string>>
    {
        virtual StringView type_name() const override { return "a string or array of strings"; }

        virtual Optional<std::vector<std::string>> visit_string(Reader&, StringView, StringView sv) override
        {
            std::vector<std::string> out;
            out.push_back(sv.to_string());
            return out;
        }

        virtual Optional<std::vector<std::string>> visit_array(Reader& r, StringView key, const Array& arr) override
        {
            return r.array_elements(arr, key, StringDeserializer{"a string"});
        }
    };

    struct IdentifierDeserializer final : Json::IDeserializer<std::string>
    {
        virtual StringView type_name() const override { return "an identifier"; }

        // [a-z0-9]+(-[a-z0-9]+)*, plus not any of {prn, aux, nul, con, lpt[1-9], com[1-9], core, default}
        static bool is_ident(StringView sv);

        virtual Optional<std::string> visit_string(Json::Reader&, StringView, StringView sv) override
        {
            if (is_ident(sv))
            {
                return sv.to_string();
            }
            else
            {
                return nullopt;
            }
        }
    };

    struct PackageNameDeserializer final : Json::IDeserializer<std::string>
    {
        virtual StringView type_name() const override { return "a package name"; }

        static bool is_package_name(StringView sv)
        {
            if (sv.size() == 0)
            {
                return false;
            }

            for (const auto& ident : Strings::split(sv, '.'))
            {
                if (!IdentifierDeserializer::is_ident(ident))
                {
                    return false;
                }
            }

            return true;
        }

        virtual Optional<std::string> visit_string(Json::Reader&, StringView, StringView sv) override
        {
            if (!is_package_name(sv))
            {
                return nullopt;
            }
            return sv.to_string();
        }
    };

    ExpectedT<std::pair<Value, JsonStyle>, std::unique_ptr<Parse::IParseError>> parse_file(
        const Files::Filesystem&, const fs::path&, std::error_code& ec) noexcept;
    ExpectedT<std::pair<Value, JsonStyle>, std::unique_ptr<Parse::IParseError>> parse(
        StringView text, const fs::path& filepath = {}) noexcept;
    std::pair<Value, JsonStyle> parse_file(vcpkg::LineInfo linfo, const Files::Filesystem&, const fs::path&) noexcept;

    std::string stringify(const Value&, JsonStyle style);
    std::string stringify(const Object&, JsonStyle style);
    std::string stringify(const Array&, JsonStyle style);

}
