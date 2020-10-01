#include <vcpkg/base/files.h>
#include <vcpkg/base/json.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/unicode.h>

#include <inttypes.h>

#include <regex>

namespace vcpkg::Json
{
    using VK = ValueKind;

    // struct Value {
    namespace impl
    {
        // TODO: add a value_kind value template once we get rid of VS2015 support
        template<ValueKind Vk>
        using ValueKindConstant = std::integral_constant<ValueKind, Vk>;

        struct ValueImpl
        {
            VK tag;
            union
            {
                std::nullptr_t null;
                bool boolean;
                int64_t integer;
                double number;
                std::string string;
                Array array;
                Object object;
            };

            ValueImpl(ValueKindConstant<VK::Null> vk, std::nullptr_t) : tag(vk), null() { }
            ValueImpl(ValueKindConstant<VK::Boolean> vk, bool b) : tag(vk), boolean(b) { }
            ValueImpl(ValueKindConstant<VK::Integer> vk, int64_t i) : tag(vk), integer(i) { }
            ValueImpl(ValueKindConstant<VK::Number> vk, double d) : tag(vk), number(d) { }
            ValueImpl(ValueKindConstant<VK::String> vk, std::string&& s) : tag(vk), string(std::move(s)) { }
            ValueImpl(ValueKindConstant<VK::String> vk, const std::string& s) : tag(vk), string(s) { }
            ValueImpl(ValueKindConstant<VK::Array> vk, Array&& arr) : tag(vk), array(std::move(arr)) { }
            ValueImpl(ValueKindConstant<VK::Array> vk, const Array& arr) : tag(vk), array(arr) { }
            ValueImpl(ValueKindConstant<VK::Object> vk, Object&& obj) : tag(vk), object(std::move(obj)) { }
            ValueImpl(ValueKindConstant<VK::Object> vk, const Object& obj) : tag(vk), object(obj) { }

            ValueImpl& operator=(ValueImpl&& other) noexcept
            {
                switch (other.tag)
                {
                    case VK::Null: return internal_assign(VK::Null, &ValueImpl::null, other);
                    case VK::Boolean: return internal_assign(VK::Boolean, &ValueImpl::boolean, other);
                    case VK::Integer: return internal_assign(VK::Integer, &ValueImpl::integer, other);
                    case VK::Number: return internal_assign(VK::Number, &ValueImpl::number, other);
                    case VK::String: return internal_assign(VK::String, &ValueImpl::string, other);
                    case VK::Array: return internal_assign(VK::Array, &ValueImpl::array, other);
                    case VK::Object: return internal_assign(VK::Object, &ValueImpl::object, other);
                }
            }

            ~ValueImpl() { destroy_underlying(); }

        private:
            template<class T>
            ValueImpl& internal_assign(ValueKind vk, T ValueImpl::*mp, ValueImpl& other) noexcept
            {
                if (tag == vk)
                {
                    this->*mp = std::move(other.*mp);
                }
                else
                {
                    destroy_underlying();
                    new (&(this->*mp)) T(std::move(other.*mp));
                    tag = vk;
                }

                return *this;
            }

            void destroy_underlying() noexcept
            {
                switch (tag)
                {
                    case VK::String: string.~basic_string(); break;
                    case VK::Array: array.~Array(); break;
                    case VK::Object: object.~Object(); break;
                    default: break;
                }
                new (&null) std::nullptr_t();
                tag = VK::Null;
            }
        };
    }

    using impl::ValueImpl;
    using impl::ValueKindConstant;

    VK Value::kind() const noexcept
    {
        if (underlying_)
        {
            return underlying_->tag;
        }
        else
        {
            return VK::Null;
        }
    }

    bool Value::is_null() const noexcept { return kind() == VK::Null; }
    bool Value::is_boolean() const noexcept { return kind() == VK::Boolean; }
    bool Value::is_integer() const noexcept { return kind() == VK::Integer; }
    bool Value::is_number() const noexcept
    {
        auto k = kind();
        return k == VK::Integer || k == VK::Number;
    }
    bool Value::is_string() const noexcept { return kind() == VK::String; }
    bool Value::is_array() const noexcept { return kind() == VK::Array; }
    bool Value::is_object() const noexcept { return kind() == VK::Object; }

    bool Value::boolean() const noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, is_boolean());
        return underlying_->boolean;
    }
    int64_t Value::integer() const noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, is_integer());
        return underlying_->integer;
    }
    double Value::number() const noexcept
    {
        auto k = kind();
        if (k == VK::Number)
        {
            return underlying_->number;
        }
        else
        {
            return static_cast<double>(integer());
        }
    }
    StringView Value::string() const noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, is_string(), "json value is not string");
        return underlying_->string;
    }

    const Array& Value::array() const& noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, is_array(), "json value is not array");
        return underlying_->array;
    }
    Array& Value::array() & noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, is_array(), "json value is not array");
        return underlying_->array;
    }
    Array&& Value::array() && noexcept { return std::move(this->array()); }

    const Object& Value::object() const& noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, is_object(), "json value is not object");
        return underlying_->object;
    }
    Object& Value::object() & noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, is_object(), "json value is not object");
        return underlying_->object;
    }
    Object&& Value::object() && noexcept { return std::move(this->object()); }

    Value::Value() noexcept = default;
    Value::Value(Value&&) noexcept = default;
    Value& Value::operator=(Value&&) noexcept = default;

    Value::Value(const Value& other)
    {
        switch (other.kind())
        {
            case ValueKind::Null: return; // default construct underlying_
            case ValueKind::Boolean:
                underlying_.reset(new ValueImpl(ValueKindConstant<VK::Boolean>(), other.underlying_->boolean));
                break;
            case ValueKind::Integer:
                underlying_.reset(new ValueImpl(ValueKindConstant<VK::Integer>(), other.underlying_->integer));
                break;
            case ValueKind::Number:
                underlying_.reset(new ValueImpl(ValueKindConstant<VK::Number>(), other.underlying_->number));
                break;
            case ValueKind::String:
                underlying_.reset(new ValueImpl(ValueKindConstant<VK::String>(), other.underlying_->string));
                break;
            case ValueKind::Array:
                underlying_.reset(new ValueImpl(ValueKindConstant<VK::Array>(), other.underlying_->array));
                break;
            case ValueKind::Object:
                underlying_.reset(new ValueImpl(ValueKindConstant<VK::Object>(), other.underlying_->object));
                break;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    Value& Value::operator=(const Value& other)
    {
        switch (other.kind())
        {
            case ValueKind::Null: underlying_.reset(); break;
            case ValueKind::Boolean:
                underlying_.reset(new ValueImpl(ValueKindConstant<VK::Boolean>(), other.underlying_->boolean));
                break;
            case ValueKind::Integer:
                underlying_.reset(new ValueImpl(ValueKindConstant<VK::Integer>(), other.underlying_->integer));
                break;
            case ValueKind::Number:
                underlying_.reset(new ValueImpl(ValueKindConstant<VK::Number>(), other.underlying_->number));
                break;
            case ValueKind::String:
                underlying_.reset(new ValueImpl(ValueKindConstant<VK::String>(), other.underlying_->string));
                break;
            case ValueKind::Array:
                underlying_.reset(new ValueImpl(ValueKindConstant<VK::Array>(), other.underlying_->array));
                break;
            case ValueKind::Object:
                underlying_.reset(new ValueImpl(ValueKindConstant<VK::Object>(), other.underlying_->object));
                break;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }

        return *this;
    }

    Value::~Value() = default;

    Value Value::null(std::nullptr_t) noexcept { return Value(); }
    Value Value::boolean(bool b) noexcept
    {
        Value val;
        val.underlying_ = std::make_unique<ValueImpl>(ValueKindConstant<VK::Boolean>(), b);
        return val;
    }
    Value Value::integer(int64_t i) noexcept
    {
        Value val;
        val.underlying_ = std::make_unique<ValueImpl>(ValueKindConstant<VK::Integer>(), i);
        return val;
    }
    Value Value::number(double d) noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, isfinite(d));
        Value val;
        val.underlying_ = std::make_unique<ValueImpl>(ValueKindConstant<VK::Number>(), d);
        return val;
    }
    Value Value::string(std::string s) noexcept
    {
        if (!Unicode::utf8_is_valid_string(s.data(), s.data() + s.size()))
        {
            Debug::print("Invalid string: ", s, '\n');
            vcpkg::Checks::exit_with_message(VCPKG_LINE_INFO, "Invalid utf8 passed to Value::string(std::string)");
        }
        Value val;
        val.underlying_ = std::make_unique<ValueImpl>(ValueKindConstant<VK::String>(), std::move(s));
        return val;
    }
    Value Value::array(Array&& arr) noexcept
    {
        Value val;
        val.underlying_ = std::make_unique<ValueImpl>(ValueKindConstant<VK::Array>(), std::move(arr));
        return val;
    }
    Value Value::array(const Array& arr) noexcept
    {
        Value val;
        val.underlying_ = std::make_unique<ValueImpl>(ValueKindConstant<VK::Array>(), arr);
        return val;
    }
    Value Value::object(Object&& obj) noexcept
    {
        Value val;
        val.underlying_ = std::make_unique<ValueImpl>(ValueKindConstant<VK::Object>(), std::move(obj));
        return val;
    }
    Value Value::object(const Object& obj) noexcept
    {
        Value val;
        val.underlying_ = std::make_unique<ValueImpl>(ValueKindConstant<VK::Object>(), obj);
        return val;
    }

    bool operator==(const Value& lhs, const Value& rhs)
    {
        if (lhs.kind() != rhs.kind()) return false;

        switch (lhs.kind())
        {
            case ValueKind::Null: return true;
            case ValueKind::Boolean: return lhs.underlying_->boolean == rhs.underlying_->boolean;
            case ValueKind::Integer: return lhs.underlying_->integer == rhs.underlying_->integer;
            case ValueKind::Number: return lhs.underlying_->number == rhs.underlying_->number;
            case ValueKind::String: return lhs.underlying_->string == rhs.underlying_->string;
            case ValueKind::Array: return lhs.underlying_->string == rhs.underlying_->string;
            case ValueKind::Object: return lhs.underlying_->string == rhs.underlying_->string;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }
    // } struct Value
    // struct Array {
    Value& Array::push_back(Value&& value)
    {
        underlying_.push_back(std::move(value));
        return underlying_.back();
    }
    Object& Array::push_back(Object&& obj) { return push_back(Value::object(std::move(obj))).object(); }
    Array& Array::push_back(Array&& arr) { return push_back(Value::array(std::move(arr))).array(); }
    Value& Array::insert_before(iterator it, Value&& value)
    {
        size_t index = it - underlying_.begin();
        underlying_.insert(it, std::move(value));
        return underlying_[index];
    }
    Object& Array::insert_before(iterator it, Object&& obj)
    {
        return insert_before(it, Value::object(std::move(obj))).object();
    }
    Array& Array::insert_before(iterator it, Array&& arr)
    {
        return insert_before(it, Value::array(std::move(arr))).array();
    }
    bool operator==(const Array& lhs, const Array& rhs) { return lhs.underlying_ == rhs.underlying_; }
    // } struct Array
    // struct Object {
    Value& Object::insert(std::string key, Value&& value)
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, !contains(key));
        underlying_.push_back({std::move(key), std::move(value)});
        return underlying_.back().second;
    }
    Value& Object::insert(std::string key, const Value& value)
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, !contains(key));
        underlying_.push_back({std::move(key), value});
        return underlying_.back().second;
    }
    Array& Object::insert(std::string key, Array&& value)
    {
        return insert(std::move(key), Value::array(std::move(value))).array();
    }
    Array& Object::insert(std::string key, const Array& value)
    {
        return insert(std::move(key), Value::array(value)).array();
    }
    Object& Object::insert(std::string key, Object&& value)
    {
        return insert(std::move(key), Value::object(std::move(value))).object();
    }
    Object& Object::insert(std::string key, const Object& value)
    {
        return insert(std::move(key), Value::object(value)).object();
    }

    Value& Object::insert_or_replace(std::string key, Value&& value)
    {
        auto v = get(key);
        if (v)
        {
            *v = std::move(value);
            return *v;
        }
        else
        {
            underlying_.push_back({std::move(key), std::move(value)});
            return underlying_.back().second;
        }
    }
    Value& Object::insert_or_replace(std::string key, const Value& value)
    {
        auto v = get(key);
        if (v)
        {
            *v = value;
            return *v;
        }
        else
        {
            underlying_.push_back({std::move(key), std::move(value)});
            return underlying_.back().second;
        }
    }
    Array& Object::insert_or_replace(std::string key, Array&& value)
    {
        return insert_or_replace(std::move(key), Value::array(std::move(value))).array();
    }
    Array& Object::insert_or_replace(std::string key, const Array& value)
    {
        return insert_or_replace(std::move(key), Value::array(value)).array();
    }
    Object& Object::insert_or_replace(std::string key, Object&& value)
    {
        return insert_or_replace(std::move(key), Value::object(std::move(value))).object();
    }
    Object& Object::insert_or_replace(std::string key, const Object& value)
    {
        return insert_or_replace(std::move(key), Value::object(value)).object();
    }

    auto Object::internal_find_key(StringView key) const noexcept -> underlying_t::const_iterator
    {
        return std::find_if(
            underlying_.begin(), underlying_.end(), [key](const auto& pair) { return pair.first == key; });
    }

    // returns whether the key existed
    bool Object::remove(StringView key) noexcept
    {
        auto it = internal_find_key(key);
        if (it == underlying_.end())
        {
            return false;
        }
        else
        {
            underlying_.erase(it);
            return true;
        }
    }

    Value* Object::get(StringView key) noexcept
    {
        auto it = internal_find_key(key);
        if (it == underlying_.end())
        {
            return nullptr;
        }
        else
        {
            return &underlying_[it - underlying_.begin()].second;
        }
    }
    const Value* Object::get(StringView key) const noexcept
    {
        auto it = internal_find_key(key);
        if (it == underlying_.end())
        {
            return nullptr;
        }
        else
        {
            return &it->second;
        }
    }

    void Object::sort_keys()
    {
        std::sort(underlying_.begin(), underlying_.end(), [](const value_type& lhs, const value_type& rhs) {
            return lhs.first < rhs.first;
        });
    }

    bool operator==(const Object& lhs, const Object& rhs) { return lhs.underlying_ == rhs.underlying_; }
    // } struct Object

    // auto parse() {
    namespace
    {
        struct Parser : private Parse::ParserBase
        {
            Parser(StringView text, StringView origin) : Parse::ParserBase(text, origin), style_() { }

            char32_t next() noexcept
            {
                auto ch = cur();
                if (ch == '\r') style_.newline_kind = JsonStyle::Newline::CrLf;
                if (ch == '\t') style_.set_tabs();
                return Parse::ParserBase::next();
            }

            static constexpr bool is_digit(char32_t code_point) noexcept
            {
                return code_point >= '0' && code_point <= '9';
            }
            static constexpr bool is_hex_digit(char32_t code_point) noexcept
            {
                return is_digit(code_point) || (code_point >= 'a' && code_point <= 'f') ||
                       (code_point >= 'A' && code_point <= 'F');
            }
            static bool is_number_start(char32_t code_point) noexcept
            {
                return code_point == '-' || is_digit(code_point);
            }

            static unsigned char from_hex_digit(char32_t code_point) noexcept
            {
                if (is_digit(code_point))
                {
                    return static_cast<unsigned char>(code_point) - '0';
                }
                else if (code_point >= 'a' && code_point <= 'f')
                {
                    return static_cast<unsigned char>(code_point) - 'a' + 10;
                }
                else if (code_point >= 'A' && code_point <= 'F')
                {
                    return static_cast<unsigned char>(code_point) - 'A' + 10;
                }
                else
                {
                    vcpkg::Checks::unreachable(VCPKG_LINE_INFO);
                }
            }

            // parses a _single_ code point of a string -- either a literal code point, or an escape sequence
            // returns end_of_file if it reaches an unescaped '"'
            // _does not_ pair escaped surrogates -- returns the literal surrogate.
            char32_t parse_string_code_point() noexcept
            {
                char32_t current = cur();
                if (current == '"')
                {
                    next();
                    return Unicode::end_of_file;
                }
                else if (current <= 0x001F)
                {
                    add_error("Control character in string");
                    next();
                    return Unicode::end_of_file;
                }
                else if (current != '\\')
                {
                    next();
                    return current;
                }

                // cur == '\\'
                if (at_eof())
                {
                    add_error("Unexpected EOF after escape character");
                    return Unicode::end_of_file;
                }
                current = next();

                switch (current)
                {
                    case '"': next(); return '"';
                    case '\\': next(); return '\\';
                    case '/': next(); return '/';
                    case 'b': next(); return '\b';
                    case 'f': next(); return '\f';
                    case 'n': next(); return '\n';
                    case 'r': next(); return '\r';
                    case 't': next(); return '\t';
                    case 'u':
                    {
                        char16_t code_unit = 0;
                        for (int i = 0; i < 4; ++i)
                        {
                            current = next();

                            if (current == Unicode::end_of_file)
                            {
                                add_error("Unexpected end of file in middle of unicode escape");
                                return Unicode::end_of_file;
                            }
                            if (is_hex_digit(current))
                            {
                                code_unit *= 16;
                                code_unit += from_hex_digit(current);
                            }
                            else
                            {
                                add_error("Invalid hex digit in unicode escape");
                                return Unicode::end_of_file;
                            }
                        }
                        next();

                        return code_unit;
                    }
                    default: add_error("Unexpected escape sequence continuation"); return Unicode::end_of_file;
                }
            }

            std::string parse_string() noexcept
            {
                Checks::check_exit(VCPKG_LINE_INFO, cur() == '"');
                next();

                std::string res;
                char32_t previous_leading_surrogate = Unicode::end_of_file;
                while (!at_eof())
                {
                    auto code_point = parse_string_code_point();

                    if (previous_leading_surrogate != Unicode::end_of_file)
                    {
                        if (Unicode::utf16_is_trailing_surrogate_code_point(code_point))
                        {
                            const auto full_code_point =
                                Unicode::utf16_surrogates_to_code_point(previous_leading_surrogate, code_point);
                            Unicode::utf8_append_code_point(res, full_code_point);
                            previous_leading_surrogate = Unicode::end_of_file;
                            continue;
                        }
                        else
                        {
                            Unicode::utf8_append_code_point(res, previous_leading_surrogate);
                        }
                    }
                    previous_leading_surrogate = Unicode::end_of_file;

                    if (Unicode::utf16_is_leading_surrogate_code_point(code_point))
                    {
                        previous_leading_surrogate = code_point;
                    }
                    else if (code_point == Unicode::end_of_file)
                    {
                        return res;
                    }
                    else
                    {
                        Unicode::utf8_append_code_point(res, code_point);
                    }
                }

                add_error("Unexpected EOF in middle of string");
                return res;
            }

            Value parse_number() noexcept
            {
                Checks::check_exit(VCPKG_LINE_INFO, is_number_start(cur()));

                bool floating = false;
                bool negative = false; // negative & 0 -> floating, so keep track of it
                std::string number_to_parse;

                char32_t current = cur();
                if (cur() == '-')
                {
                    number_to_parse.push_back('-');
                    negative = true;
                    current = next();
                    if (current == Unicode::end_of_file)
                    {
                        add_error("Unexpected EOF after minus sign");
                        return Value();
                    }
                }

                if (current == '0')
                {
                    current = next();
                    if (current == '.')
                    {
                        number_to_parse.append("0.");
                        floating = true;
                        current = next();
                    }
                    else if (is_digit(current))
                    {
                        add_error("Unexpected digits after a leading zero");
                        return Value();
                    }
                    else
                    {
                        if (negative)
                        {
                            return Value::number(-0.0);
                        }
                        else
                        {
                            return Value::integer(0);
                        }
                    }
                }

                while (is_digit(current))
                {
                    number_to_parse.push_back(static_cast<char>(current));
                    current = next();
                }
                if (!floating && current == '.')
                {
                    floating = true;
                    number_to_parse.push_back('.');
                    current = next();
                    if (!is_digit(current))
                    {
                        add_error("Expected digits after the decimal point");
                        return Value();
                    }
                    while (is_digit(current))
                    {
                        number_to_parse.push_back(static_cast<char>(current));
                        current = next();
                    }
                }

                if (floating)
                {
                    auto opt = Strings::strto<double>(number_to_parse);
                    if (auto res = opt.get())
                    {
                        if (std::abs(*res) < INFINITY)
                        {
                            return Value::number(*res);
                        }
                        else
                        {
                            add_error(Strings::format("Floating point constant too big: %s", number_to_parse));
                        }
                    }
                    else
                    {
                        add_error(Strings::format("Invalid floating point constant: %s", number_to_parse));
                    }
                }
                else
                {
                    auto opt = Strings::strto<int64_t>(number_to_parse);
                    if (auto res = opt.get())
                    {
                        return Value::integer(*res);
                    }
                    else
                    {
                        add_error(Strings::format("Invalid integer constant: %s", number_to_parse));
                    }
                }

                return Value();
            }

            Value parse_keyword() noexcept
            {
                char32_t current = cur();
                const char32_t* rest;
                Value val;
                switch (current)
                {
                    case 't': // parse true
                        rest = U"rue";
                        val = Value::boolean(true);
                        break;
                    case 'f': // parse false
                        rest = U"alse";
                        val = Value::boolean(false);
                        break;
                    case 'n': // parse null
                        rest = U"ull";
                        val = Value::null(nullptr);
                        break;
                    default: vcpkg::Checks::unreachable(VCPKG_LINE_INFO);
                }

                for (const char32_t* rest_it = rest; *rest_it != '\0'; ++rest_it)
                {
                    current = next();

                    if (current == Unicode::end_of_file)
                    {
                        add_error("Unexpected EOF in middle of keyword");
                        return Value();
                    }
                    if (current != *rest_it)
                    {
                        add_error("Unexpected character in middle of keyword");
                    }
                }
                next();

                return val;
            }

            Value parse_array() noexcept
            {
                Checks::check_exit(VCPKG_LINE_INFO, cur() == '[');
                next();

                Array arr;
                bool first = true;
                for (;;)
                {
                    skip_whitespace();

                    char32_t current = cur();
                    if (current == Unicode::end_of_file)
                    {
                        add_error("Unexpected EOF in middle of array");
                        return Value();
                    }
                    if (current == ']')
                    {
                        next();
                        return Value::array(std::move(arr));
                    }

                    if (first)
                    {
                        first = false;
                    }
                    else if (current == ',')
                    {
                        auto comma_loc = cur_loc();
                        next();
                        skip_whitespace();
                        current = cur();
                        if (current == Unicode::end_of_file)
                        {
                            add_error("Unexpected EOF in middle of array");
                            return Value();
                        }
                        if (current == ']')
                        {
                            add_error("Trailing comma in array", comma_loc);
                            return Value::array(std::move(arr));
                        }
                    }
                    else
                    {
                        add_error("Unexpected character in middle of array");
                        return Value();
                    }

                    arr.push_back(parse_value());
                }
            }

            std::pair<std::string, Value> parse_kv_pair() noexcept
            {
                skip_whitespace();

                auto current = cur();

                std::pair<std::string, Value> res = {std::string(""), Value()};

                if (current == Unicode::end_of_file)
                {
                    add_error("Unexpected EOF; expected property name");
                    return res;
                }
                if (current != '"')
                {
                    add_error("Unexpected character; expected property name");
                    return res;
                }
                res.first = parse_string();

                skip_whitespace();
                current = cur();
                if (current == ':')
                {
                    next();
                }
                else if (current == Unicode::end_of_file)
                {
                    add_error("Unexpected EOF; expected colon");
                    return res;
                }
                else
                {
                    add_error("Unexpected character; expected colon");
                    return res;
                }

                res.second = parse_value();

                return res;
            }

            Value parse_object() noexcept
            {
                char32_t current = cur();

                Checks::check_exit(VCPKG_LINE_INFO, current == '{');
                next();

                Object obj;
                bool first = true;
                for (;;)
                {
                    skip_whitespace();
                    current = cur();
                    if (current == Unicode::end_of_file)
                    {
                        add_error("Unexpected EOF; expected property or close brace");
                        return Value();
                    }
                    else if (current == '}')
                    {
                        next();
                        return Value::object(std::move(obj));
                    }

                    if (first)
                    {
                        first = false;
                    }
                    else if (current == ',')
                    {
                        auto comma_loc = cur_loc();
                        next();
                        skip_whitespace();
                        current = cur();
                        if (current == Unicode::end_of_file)
                        {
                            add_error("Unexpected EOF; expected property");
                            return Value();
                        }
                        else if (current == '}')
                        {
                            add_error("Trailing comma in an object", comma_loc);
                            return Value();
                        }
                    }
                    else
                    {
                        add_error("Unexpected character; expected comma or close brace");
                    }

                    auto val = parse_kv_pair();
                    obj.insert(std::move(val.first), std::move(val.second));
                }
            }

            Value parse_value() noexcept
            {
                skip_whitespace();
                char32_t current = cur();
                if (current == Unicode::end_of_file)
                {
                    add_error("Unexpected EOF; expected value");
                    return Value();
                }

                switch (current)
                {
                    case '{': return parse_object();
                    case '[': return parse_array();
                    case '"': return Value::string(parse_string());
                    case 'n':
                    case 't':
                    case 'f': return parse_keyword();
                    default:
                        if (is_number_start(current))
                        {
                            return parse_number();
                        }
                        else
                        {
                            add_error("Unexpected character; expected value");
                            return Value();
                        }
                }
            }

            static ExpectedT<std::pair<Value, JsonStyle>, std::unique_ptr<Parse::IParseError>> parse(
                StringView json, StringView origin) noexcept
            {
                auto parser = Parser(json, origin);

                auto val = parser.parse_value();

                parser.skip_whitespace();
                if (!parser.at_eof())
                {
                    parser.add_error("Unexpected character; expected EOF");
                    return std::move(parser).extract_error();
                }
                else if (parser.get_error())
                {
                    return std::move(parser).extract_error();
                }
                else
                {
                    return std::make_pair(std::move(val), parser.style());
                }
            }

            JsonStyle style() const noexcept { return style_; }

        private:
            JsonStyle style_;
        };
    }

    bool IdentifierDeserializer::is_ident(StringView sv)
    {
        static const std::regex BASIC_IDENTIFIER = std::regex(R"([a-z0-9]+(-[a-z0-9]+)*)");

        // we only check for lowercase in RESERVED since we already remove all
        // strings with uppercase letters from the basic check
        static const std::regex RESERVED = std::regex(R"(prn|aux|nul|con|(lpt|com)[1-9]|core|default)");

        // back-compat
        if (sv == "all_modules")
        {
            return true;
        }

        if (!std::regex_match(sv.begin(), sv.end(), BASIC_IDENTIFIER))
        {
            return false; // we're not even in the shape of an identifier
        }

        if (std::regex_match(sv.begin(), sv.end(), RESERVED))
        {
            return false; // we're a reserved identifier
        }

        return true;
    }

    ExpectedT<std::pair<Value, JsonStyle>, std::unique_ptr<Parse::IParseError>> parse_file(const Files::Filesystem& fs,
                                                                                           const fs::path& path,
                                                                                           std::error_code& ec) noexcept
    {
        auto res = fs.read_contents(path);
        if (auto buf = res.get())
        {
            return parse(*buf, path);
        }
        else
        {
            ec = res.error();
            return std::unique_ptr<Parse::IParseError>();
        }
    }

    std::pair<Value, JsonStyle> parse_file(vcpkg::LineInfo linfo,
                                           const Files::Filesystem& fs,
                                           const fs::path& path) noexcept
    {
        std::error_code ec;
        auto ret = parse_file(fs, path, ec);
        if (ec)
        {
            System::print2(System::Color::error, "Failed to read ", fs::u8string(path), ": ", ec.message(), "\n");
            Checks::exit_fail(linfo);
        }
        else if (!ret)
        {
            System::print2(System::Color::error, "Failed to parse ", fs::u8string(path), ":\n");
            System::print2(ret.error()->format());
            Checks::exit_fail(linfo);
        }
        return ret.value_or_exit(linfo);
    }

    ExpectedT<std::pair<Value, JsonStyle>, std::unique_ptr<Parse::IParseError>> parse(StringView json,
                                                                                      const fs::path& filepath) noexcept
    {
        return Parser::parse(json, fs::generic_u8string(filepath));
    }
    // } auto parse()

    namespace
    {
        struct Stringifier
        {
            JsonStyle style;
            std::string& buffer;

            void append_indent(int indent)
            {
                if (style.use_tabs())
                {
                    buffer.append(indent, '\t');
                }
                else
                {
                    buffer.append(indent * style.spaces(), ' ');
                }
            };

            void append_unicode_escape(char16_t code_unit)
            {
                buffer.append("\\u");

                // AFAIK, there's no standard way of doing this?
                constexpr const char hex_digit[16] = {
                    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};

                buffer.push_back(hex_digit[(code_unit >> 12) & 0x0F]);
                buffer.push_back(hex_digit[(code_unit >> 8) & 0x0F]);
                buffer.push_back(hex_digit[(code_unit >> 4) & 0x0F]);
                buffer.push_back(hex_digit[(code_unit >> 0) & 0x0F]);
            }

            // taken from the ECMAScript 2020 standard, 24.5.2.2: Runtime Semantics: QuoteJSONString
            void append_quoted_json_string(StringView sv)
            {
                // Table 66: JSON Single Character Escape Sequences
                constexpr static std::array<std::pair<char32_t, const char*>, 7> escape_sequences = {{
                    {0x0008, R"(\b)"}, // BACKSPACE
                    {0x0009, R"(\t)"}, // CHARACTER TABULATION
                    {0x000A, R"(\n)"}, // LINE FEED (LF)
                    {0x000C, R"(\f)"}, // FORM FEED (FF)
                    {0x000D, R"(\r)"}, // CARRIAGE RETURN (CR)
                    {0x0022, R"(\")"}, // QUOTATION MARK
                    {0x005C, R"(\\)"}  // REVERSE SOLIDUS
                }};
                // 1. Let product be the String value consisting solely of the code unit 0x0022 (QUOTATION MARK).
                buffer.push_back('"');

                // 2. For each code point C in ! UTF16DecodeString(value), do
                // (note that we use utf8 instead of utf16)
                for (auto code_point : Unicode::Utf8Decoder(sv.begin(), sv.end()))
                {
                    // a. If C is listed in the "Code Point" column of Table 66, then
                    const auto match = std::find_if(begin(escape_sequences),
                                                    end(escape_sequences),
                                                    [code_point](const std::pair<char32_t, const char*>& attempt) {
                                                        return attempt.first == code_point;
                                                    });
                    // i. Set product to the string-concatenation of product and the escape sequence for C as
                    // specified in the "Escape Sequence" column of the corresponding row.
                    if (match != end(escape_sequences))
                    {
                        buffer.append(match->second);
                        continue;
                    }

                    // b. Else if C has a numeric value less than 0x0020 (SPACE), or if C has the same numeric value as
                    // a leading surrogate or trailing surrogate, then
                    if (code_point < 0x0020 || Unicode::utf16_is_surrogate_code_point(code_point))
                    {
                        // i. Let unit be the code unit whose numeric value is that of C.
                        // ii. Set product to the string-concatenation of product and UnicodeEscape(unit).
                        append_unicode_escape(static_cast<char16_t>(code_point));
                        break;
                    }

                    // c. Else,
                    // i. Set product to the string-concatenation of product and the UTF16Encoding of C.
                    // (again, we use utf-8 here instead)
                    Unicode::utf8_append_code_point(buffer, code_point);
                }

                // 3. Set product to the string-concatenation of product and the code unit 0x0022 (QUOTATION MARK).
                buffer.push_back('"');
            }

            void stringify_object(const Object& obj, int current_indent)
            {
                buffer.push_back('{');
                if (obj.size() != 0)
                {
                    bool first = true;

                    for (const auto& el : obj)
                    {
                        if (!first)
                        {
                            buffer.push_back(',');
                        }
                        first = false;

                        buffer.append(style.newline());
                        append_indent(current_indent + 1);

                        append_quoted_json_string(el.first);
                        buffer.append(": ");
                        stringify(el.second, current_indent + 1);
                    }
                    buffer.append(style.newline());
                    append_indent(current_indent);
                }
                buffer.push_back('}');
            }

            void stringify_array(const Array& arr, int current_indent)
            {
                buffer.push_back('[');
                if (arr.size() == 0)
                {
                    buffer.push_back(']');
                }
                else
                {
                    bool first = true;

                    for (const auto& el : arr)
                    {
                        if (!first)
                        {
                            buffer.push_back(',');
                        }
                        first = false;

                        buffer.append(style.newline());
                        append_indent(current_indent + 1);

                        stringify(el, current_indent + 1);
                    }
                    buffer.append(style.newline());
                    append_indent(current_indent);
                    buffer.push_back(']');
                }
            }

            void stringify(const Value& value, int current_indent)
            {
                switch (value.kind())
                {
                    case VK::Null: buffer.append("null"); break;
                    case VK::Boolean:
                    {
                        auto v = value.boolean();
                        buffer.append(v ? "true" : "false");
                        break;
                    }
                    // TODO: switch to `to_chars` once we are able to remove support for old compilers
                    case VK::Integer: buffer.append(std::to_string(value.integer())); break;
                    case VK::Number: buffer.append(std::to_string(value.number())); break;
                    case VK::String:
                    {
                        append_quoted_json_string(value.string());
                        break;
                    }
                    case VK::Array:
                    {
                        stringify_array(value.array(), current_indent);
                        break;
                    }
                    case VK::Object:
                    {
                        stringify_object(value.object(), current_indent);
                        break;
                    }
                }
            }
        };
    }

    std::string stringify(const Value& value, JsonStyle style)
    {
        std::string res;
        Stringifier{style, res}.stringify(value, 0);
        res.push_back('\n');
        return res;
    }
    std::string stringify(const Object& obj, JsonStyle style)
    {
        std::string res;
        Stringifier{style, res}.stringify_object(obj, 0);
        res.push_back('\n');
        return res;
    }
    std::string stringify(const Array& arr, JsonStyle style)
    {
        std::string res;
        Stringifier{style, res}.stringify_array(arr, 0);
        res.push_back('\n');
        return res;
    }
    // } auto stringify()

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

    void Reader::check_for_unexpected_fields(const Object& obj,
                                             Span<const StringView> valid_fields,
                                             StringView type_name)
    {
        if (valid_fields.size() == 0)
        {
            return;
        }

        auto extra_fields = invalid_json_fields(obj, valid_fields);
        if (!extra_fields.empty())
        {
            add_extra_fields_error(type_name.to_string(), std::move(extra_fields));
        }
    }

    std::string Reader::path() const noexcept
    {
        std::string p("$");
        for (auto&& s : m_path)
        {
            if (s.index < 0)
                Strings::append(p, '.', s.field);
            else
                Strings::append(p, '[', s.index, ']');
        }
        return p;
    }

}
