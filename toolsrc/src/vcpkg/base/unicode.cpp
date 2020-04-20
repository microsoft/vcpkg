#include "pch.h"

#include <vcpkg/base/unicode.h>

#include <vcpkg/base/checks.h>

namespace vcpkg::Unicode
{
    Utf8CodeUnitKind utf8_code_unit_kind(unsigned char code_unit) noexcept
    {
        if (code_unit < 0b1000'0000)
        {
            return Utf8CodeUnitKind::StartOne;
        }
        else if (code_unit < 0b1100'0000)
        {
            return Utf8CodeUnitKind::Continue;
        }
        else if (code_unit < 0b1110'0000)
        {
            return Utf8CodeUnitKind::StartTwo;
        }
        else if (code_unit < 0b1111'0000)
        {
            return Utf8CodeUnitKind::StartThree;
        }
        else if (code_unit < 0b1111'1000)
        {
            return Utf8CodeUnitKind::StartFour;
        }
        else
        {
            return Utf8CodeUnitKind::Invalid;
        }
    }

    int utf8_code_unit_count(Utf8CodeUnitKind kind) noexcept { return static_cast<int>(kind); }
    int utf8_code_unit_count(char code_unit) noexcept { return utf8_code_unit_count(utf8_code_unit_kind(code_unit)); }

    static int utf8_encode_code_unit_count(char32_t code_point) noexcept
    {
        if (code_point < 0x80)
        {
            return 1;
        }
        else if (code_point < 0x800)
        {
            return 2;
        }
        else if (code_point < 0x10000)
        {
            return 3;
        }
        else if (code_point < 0x110000)
        {
            return 4;
        }
        else
        {
            vcpkg::Checks::exit_with_message(
                VCPKG_LINE_INFO, "Invalid code point passed to utf8_encoded_code_point_count (%x)", code_point);
        }
    }

    int utf8_encode_code_point(char (&array)[4], char32_t code_point) noexcept
    {
        // count \in {2, 3, 4}
        const auto start_code_point = [](char32_t code_point, int count) {
            const unsigned char and_mask = 0xFF >> (count + 1);
            const unsigned char or_mask = (0xFF << (8 - count)) & 0xFF;
            const int shift = 6 * (count - 1);
            return static_cast<char>(or_mask | ((code_point >> shift) & and_mask));
        };
        // count \in {2, 3, 4}, byte \in {1, 2, 3}
        const auto continue_code_point = [](char32_t code_point, int count, int byte) {
            constexpr unsigned char and_mask = 0xFF >> 2;
            constexpr unsigned char or_mask = (0xFF << 7) & 0xFF;
            const int shift = 6 * (count - byte - 1);
            return static_cast<char>(or_mask | ((code_point >> shift) & and_mask));
        };

        int count = utf8_encode_code_unit_count(code_point);
        if (count == 1)
        {
            array[0] = static_cast<char>(code_point);
            return 1;
        }

        array[0] = start_code_point(code_point, count);
        for (int i = 1; i < count; ++i)
        {
            array[i] = continue_code_point(code_point, count, i);
        }

        return count;
    }

    bool utf8_is_valid_string(const char* first, const char* last) noexcept
    {
        std::error_code ec;
        for (auto dec = Utf8Decoder(first, last); dec != dec.end(); dec.next(ec))
        {
        }
        return !ec;
    }

    char32_t utf16_surrogates_to_code_point(char32_t leading, char32_t trailing)
    {
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, utf16_is_leading_surrogate_code_point(leading));
        vcpkg::Checks::check_exit(VCPKG_LINE_INFO, utf16_is_trailing_surrogate_code_point(trailing));

        char32_t res = (leading & 0b11'1111'1111) << 10;
        res |= trailing & 0b11'1111'1111;
        res += 0x0001'0000;

        return res;
    }

    const char* utf8_category::name() const noexcept { return "utf8"; }
    std::string utf8_category::message(int condition) const
    {
        switch (static_cast<utf8_errc>(condition))
        {
            case utf8_errc::NoError: return "no error";
            case utf8_errc::InvalidCodeUnit: return "invalid code unit";
            case utf8_errc::InvalidCodePoint: return "invalid code point (>0x10FFFF)";
            case utf8_errc::PairedSurrogates:
                return "trailing surrogate following leading surrogate (paired surrogates are invalid)";
            case utf8_errc::UnexpectedContinue: return "found continue code unit in start position";
            case utf8_errc::UnexpectedStart: return "found start code unit in continue position";
            case utf8_errc::UnexpectedEof: return "found end of string in middle of code point";
            default: return "error code out of range";
        }
    }

    Utf8Decoder::Utf8Decoder() noexcept : current_(end_of_file), next_(nullptr), last_(nullptr) { }
    Utf8Decoder::Utf8Decoder(const char* first, const char* last) noexcept : current_(0), next_(first), last_(last)
    {
        if (next_ != last_)
        {
            ++*this;
        }
        else
        {
            current_ = end_of_file;
        }
    }

    char const* Utf8Decoder::pointer_to_current() const noexcept
    {
        if (is_eof())
        {
            return last_;
        }

        auto count = utf8_encode_code_unit_count(current_);
        return next_ - count;
    }

    bool Utf8Decoder::is_eof() const noexcept { return current_ == end_of_file; }
    char32_t Utf8Decoder::operator*() const noexcept
    {
        if (is_eof())
        {
            Checks::exit_with_message(VCPKG_LINE_INFO, "Dereferenced Utf8Decoder on the end of a string");
        }
        return current_;
    }

    void Utf8Decoder::next(std::error_code& ec)
    {
        ec.clear();

        if (is_eof())
        {
            vcpkg::Checks::exit_with_message(VCPKG_LINE_INFO, "Incremented Utf8Decoder at the end of the string");
        }

        if (next_ == last_)
        {
            current_ = end_of_file;
            return;
        }

        auto set_error = [&ec, this](utf8_errc err) {
            ec = err;
            *this = sentinel();
        };

        unsigned char code_unit = static_cast<unsigned char>(*next_++);

        auto kind = utf8_code_unit_kind(code_unit);
        if (kind == Utf8CodeUnitKind::Invalid)
        {
            return set_error(utf8_errc::InvalidCodeUnit);
        }
        else if (kind == Utf8CodeUnitKind::Continue)
        {
            return set_error(utf8_errc::UnexpectedContinue);
        }

        const int count = utf8_code_unit_count(kind);
        if (count == 1)
        {
            current_ = static_cast<char32_t>(code_unit);
        }
        else
        {
            // 2 -> 0b0001'1111, 6
            // 3 -> 0b0000'1111, 12
            // 4 -> 0b0000'0111, 18
            const auto start_mask = static_cast<unsigned char>(0xFF >> (count + 1));
            const int start_shift = 6 * (count - 1);
            auto code_point = static_cast<char32_t>(code_unit & start_mask) << start_shift;

            constexpr unsigned char continue_mask = 0b0011'1111;
            for (int byte = 1; byte < count; ++byte)
            {
                if (next_ == last_)
                {
                    return set_error(utf8_errc::UnexpectedContinue);
                }
                code_unit = static_cast<unsigned char>(*next_++);

                kind = utf8_code_unit_kind(code_unit);
                if (kind == Utf8CodeUnitKind::Invalid)
                {
                    return set_error(utf8_errc::InvalidCodeUnit);
                }
                else if (kind != Utf8CodeUnitKind::Continue)
                {
                    return set_error(utf8_errc::UnexpectedStart);
                }

                const int shift = 6 * (count - byte - 1);
                code_point |= (code_unit & continue_mask) << shift;
            }

            if (code_point > 0x10'FFFF)
            {
                return set_error(utf8_errc::InvalidCodePoint);
            }
            else if (utf16_is_trailing_surrogate_code_point(code_point) &&
                     utf16_is_leading_surrogate_code_point(current_))
            {
                return set_error(utf8_errc::PairedSurrogates);
            }
            else
            {
                current_ = code_point;
            }
        }
    }

    Utf8Decoder& Utf8Decoder::operator++() noexcept
    {
        std::error_code ec;
        next(ec);
        if (ec)
        {
            vcpkg::Checks::exit_with_message(VCPKG_LINE_INFO, ec.message());
        }

        return *this;
    }

    Utf8Decoder& Utf8Decoder::operator=(sentinel) noexcept
    {
        next_ = last_;
        current_ = end_of_file;
        return *this;
    }

    bool operator==(const Utf8Decoder& lhs, const Utf8Decoder& rhs) noexcept
    {
        if (lhs.last_ != rhs.last_)
        {
            Checks::exit_with_message(VCPKG_LINE_INFO,
                                      "Comparing Utf8Decoders with different provenance; this is always an error");
        }

        return lhs.next_ == rhs.next_;
    }

}
