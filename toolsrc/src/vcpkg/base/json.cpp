#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/json.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/unicode.h>

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
                int64_t number;
                std::string string;
                Array array;
                Object object;
            };

            ValueImpl(ValueKindConstant<VK::Null> vk, std::nullptr_t) : tag(vk), null() { }
            ValueImpl(ValueKindConstant<VK::Boolean> vk, bool b) : tag(vk), boolean(b) { }
            ValueImpl(ValueKindConstant<VK::Number> vk, int64_t i) : tag(vk), number(i) { }
            ValueImpl(ValueKindConstant<VK::String> vk, std::string&& s) : tag(vk), string(std::move(s)) { }
            ValueImpl(ValueKindConstant<VK::Array> vk, Array&& arr) : tag(vk), array(std::move(arr)) { }
            ValueImpl(ValueKindConstant<VK::Object> vk, Object&& obj) : tag(vk), object(std::move(obj)) { }

            ValueImpl& operator=(ValueImpl&& other) noexcept
            {
                switch (other.tag)
                {
                    case VK::Null: return internal_assign(VK::Null, &ValueImpl::null, other);
                    case VK::Boolean: return internal_assign(VK::Boolean, &ValueImpl::boolean, other);
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
    bool Value::is_number() const noexcept { return kind() == VK::Number; }
    bool Value::is_string() const noexcept { return kind() == VK::String; }
    bool Value::is_array() const noexcept { return kind() == VK::Array; }
    bool Value::is_object() const noexcept { return kind() == VK::Object; }

    bool Value::boolean() const noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, is_boolean());
        return underlying_->boolean;
    }
    int64_t Value::number() const noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, is_number());
        return underlying_->number;
    }
    StringView Value::string() const noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, is_string());
        return underlying_->string;
    }

    const Array& Value::array() const noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, is_array());
        return underlying_->array;
    }
    Array& Value::array() noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, is_array());
        return underlying_->array;
    }

    const Object& Value::object() const noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, is_object());
        return underlying_->object;
    }
    Object& Value::object() noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, is_object());
        return underlying_->object;
    }

    Value::Value() noexcept = default;
    Value::Value(Value&&) noexcept = default;
    Value& Value::operator=(Value&&) noexcept = default;
    Value::~Value() = default;

    Value Value::clone() const noexcept
    {
        switch (kind())
        {
            case ValueKind::Null: return Value::null(nullptr);
            case ValueKind::Boolean: return Value::boolean(boolean());
            case ValueKind::Number: return Value::number(number());
            case ValueKind::String: return Value::string(string());
            case ValueKind::Array: return Value::array(array().clone());
            case ValueKind::Object: return Value::object(object().clone());
            default: Checks::exit_fail(VCPKG_LINE_INFO);
        }
    }

    Value Value::null(std::nullptr_t) noexcept { return Value(); }
    Value Value::boolean(bool b) noexcept
    {
        Value val;
        val.underlying_ = std::make_unique<ValueImpl>(ValueKindConstant<VK::Boolean>(), b);
        return val;
    }
    Value Value::number(int64_t i) noexcept
    {
        Value val;
        val.underlying_ = std::make_unique<ValueImpl>(ValueKindConstant<VK::Number>(), i);
        return val;
    }
    Value Value::string(StringView sv) noexcept
    {
        if (!Unicode::utf8_is_valid_string(sv.begin(), sv.end()))
        {
            Debug::print("Invalid string: ", sv, '\n');
            vcpkg::Checks::exit_with_message(VCPKG_LINE_INFO, "Invalid utf8 passed to Value::string(StringView)");
        }
        Value val;
        val.underlying_ = std::make_unique<ValueImpl>(ValueKindConstant<VK::String>(), sv.to_string());
        return val;
    }
    Value Value::array(Array&& arr) noexcept
    {
        Value val;
        val.underlying_ = std::make_unique<ValueImpl>(ValueKindConstant<VK::Array>(), std::move(arr));
        return val;
    }
    Value Value::object(Object&& obj) noexcept
    {
        Value val;
        val.underlying_ = std::make_unique<ValueImpl>(ValueKindConstant<VK::Object>(), std::move(obj));
        return val;
    }
    // } struct Value
    // struct Array {
    Array Array::clone() const noexcept
    {
        Array arr;
        arr.underlying_.reserve(size());
        for (const auto& el : *this)
        {
            arr.underlying_.push_back(el.clone());
        }
        return arr;
    }
    // } struct Array
    // struct Object {
    void Object::insert(std::string key, Value value) noexcept
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, !contains(key));
        underlying_.push_back(std::make_pair(std::move(key), std::move(value)));
    }
    void Object::insert_or_replace(std::string key, Value value) noexcept
    {
        auto v = get(key);
        if (v)
        {
            *v = std::move(value);
        }
        else
        {
            underlying_.push_back(std::make_pair(std::move(key), std::move(value)));
        }
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

    Object Object::clone() const noexcept
    {
        Object obj;
        obj.underlying_.reserve(size());
        for (const auto& el : *this)
        {
            obj.insert(el.first.to_string(), el.second.clone());
        }
        return obj;
    }
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
            static bool is_keyword_start(char32_t code_point) noexcept
            {
                return code_point == 'f' || code_point == 'n' || code_point == 't';
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
                    vcpkg::Checks::exit_fail(VCPKG_LINE_INFO);
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
                    case '"': return '"';
                    case '\\': return '\\';
                    case '/': return '/';
                    case 'b': return '\b';
                    case 'f': return '\f';
                    case 'n': return '\n';
                    case 'r': return '\r';
                    case 't': return '\t';
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
                bool negative = false;

                char32_t current = cur();
                if (cur() == '-')
                {
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
                    if (current != Unicode::end_of_file)
                    {
                        if (is_digit(current))
                        {
                            add_error("Unexpected digits after a leading zero");
                        }
                        if (current == '.')
                        {
                            add_error("Found a `.` -- this JSON implementation does not support floating point");
                        }
                    }
                    return Value::number(0);
                }

                // parse as negative so that someone can write INT64_MIN; otherwise, they'd only be able to get
                // -INT64_MAX = INT64_MIN + 1
                constexpr auto min_value = std::numeric_limits<int64_t>::min();
                int64_t result = 0;
                while (current != Unicode::end_of_file && is_digit(current))
                {
                    const int digit = current - '0';
                    // result * 10 - digit < min_value : remember that result < 0
                    if (result < (min_value + digit) / 10)
                    {
                        add_error("Number is too big for an int64_t");
                        return Value();
                    }
                    result *= 10;
                    result -= digit;
                    current = next();
                }
                if (current == '.')
                {
                    add_error("Found a `.` -- this JSON implementation doesn't support floating point");
                    return Value();
                }

                if (!negative)
                {
                    if (result == min_value)
                    {
                        add_error("Number is too big for a uint64_t");
                        return Value();
                    }
                    result = -result;
                }

                return Value::number(result);
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
                    default: vcpkg::Checks::exit_fail(VCPKG_LINE_INFO);
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
                            add_error("Trailing comma in array");
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

                auto res = std::make_pair(std::string(""), Value());

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
                            add_error("Trailing comma in an object");
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

    ExpectedT<std::pair<Value, JsonStyle>, std::unique_ptr<Parse::IParseError>> parse(StringView json,
                                                                                      const fs::path& filepath) noexcept
    {
        return Parser::parse(json, filepath.generic_u8string());
    }
    // } auto parse()

    // auto stringify() {
    static std::string& append_unicode_escape(std::string& s, char16_t code_unit)
    {
        s.append("\\u");

        // AFAIK, there's no standard way of doing this?
        constexpr const char hex_digit[16] = {
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};

        s.push_back(hex_digit[(code_unit >> 12) & 0x0F]);
        s.push_back(hex_digit[(code_unit >> 8) & 0x0F]);
        s.push_back(hex_digit[(code_unit >> 4) & 0x0F]);
        s.push_back(hex_digit[(code_unit >> 0) & 0x0F]);

        return s;
    }

    // taken from the ECMAScript 2020 standard, 24.5.2.2: Runtime Semantics: QuoteJSONString
    static std::string& append_quoted_json_string(std::string& product, StringView sv)
    {
        // Table 66: JSON Single Character Escape Sequences
        constexpr static std::array<std::pair<char32_t, const char*>, 7> escape_sequences = {
            std::make_pair(0x0008, R"(\b)"), // BACKSPACE
            std::make_pair(0x0009, R"(\t)"), // CHARACTER TABULATION
            std::make_pair(0x000A, R"(\n)"), // LINE FEED (LF)
            std::make_pair(0x000C, R"(\f)"), // FORM FEED (FF)
            std::make_pair(0x000D, R"(\r)"), // CARRIAGE RETURN (CR)
            std::make_pair(0x0022, R"(\")"), // QUOTATION MARK
            std::make_pair(0x005C, R"(\\)")  // REVERSE SOLIDUS
        };
        // 1. Let product be the String value consisting solely of the code unit 0x0022 (QUOTATION MARK).
        product.push_back('"');

        // 2. For each code point C in ! UTF16DecodeString(value), do
        // (note that we use utf8 instead of utf16)
        for (auto code_point : Unicode::Utf8Decoder(sv.begin(), sv.end()))
        {
            bool matched = false; // early exit boolean
            // a. If C is listed in the "Code Point" column of Table 66, then
            for (auto pr : escape_sequences)
            {
                // i. Set product to the string-concatenation of product and the escape sequence for C as specified in
                // the "Escape Sequence" column of the corresponding row.
                if (code_point == pr.first)
                {
                    product.append(pr.second);
                    matched = true;
                    break;
                }
            }
            if (matched) break;

            // b. Else if C has a numeric value less than 0x0020 (SPACE), or if C has the same numeric value as a
            // leading surrogate or trailing surrogate, then
            if (code_point < 0x0020 || Unicode::utf16_is_surrogate_code_point(code_point))
            {
                // i. Let unit be the code unit whose numeric value is that of C.
                // ii. Set product to the string-concatenation of product and UnicodeEscape(unit).
                append_unicode_escape(product, static_cast<char16_t>(code_point));
                break;
            }

            // c. Else,
            // i. Set product to the string-concatenation of product and the UTF16Encoding of C.
            // (again, we use utf-8 here instead)
            Unicode::utf8_append_code_point(product, code_point);
        }

        // 3. Set product to the string-concatenation of product and the code unit 0x0022 (QUOTATION MARK).
        product.push_back('"');

        // 4. Return product.
        return product;
    }

    static std::string quote_json_string(StringView sv)
    {
        std::string product;
        append_quoted_json_string(product, sv);
        return product;
    }

    static void internal_stringify(const Value& value, JsonStyle style, std::string& buffer, int current_indent)
    {
        const auto append_indent = [&](int indent) {
            if (style.use_tabs())
            {
                buffer.append(indent, '\t');
            }
            else
            {
                buffer.append(indent * style.spaces(), ' ');
            }
        };
        switch (value.kind())
        {
            case VK::Null: buffer.append("null"); break;
            case VK::Boolean:
            {
                auto v = value.boolean();
                buffer.append(v ? "true" : "false");
                break;
            }
            case VK::Number: buffer.append(std::to_string(value.number())); break;
            case VK::String:
            {
                append_quoted_json_string(buffer, value.string());
                break;
            }
            case VK::Array:
            {
                const auto& arr = value.array();
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

                        internal_stringify(el, style, buffer, current_indent + 1);
                    }
                    buffer.append(style.newline());
                    append_indent(current_indent);
                    buffer.push_back(']');
                }
                break;
            }
            case VK::Object:
            {
                const auto& obj = value.object();
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

                        auto key = quote_json_string(el.first);
                        buffer.append(key.begin(), key.end());
                        buffer.append(": ");
                        internal_stringify(el.second, style, buffer, current_indent + 1);
                    }
                    buffer.append(style.newline());
                    append_indent(current_indent);
                }
                buffer.push_back('}');
                break;
            }
        }
    }

    std::string stringify(const Value& value, JsonStyle style) noexcept
    {
        std::string res;
        internal_stringify(value, style, res, 0);
        return res;
    }
    // } auto stringify()

}
