#pragma once
#include <system_error>

namespace vcpkg
{
    enum class paragraph_parse_result
    {
        SUCCESS = 0,
        EXPECTED_ONE_PARAGRAPH
    };

    struct paragraph_parse_result_category_impl final : std::error_category
    {
        virtual const char* name() const noexcept override;

        virtual std::string message(int ev) const noexcept override;
    };

    const std::error_category& paragraph_parse_result_category();

    std::error_code make_error_code(paragraph_parse_result e);

    paragraph_parse_result to_paragraph_parse_result(int i);

    paragraph_parse_result to_paragraph_parse_result(std::error_code ec);
}

// Enable implicit conversion to std::error_code
namespace std
{
    template <>
    struct is_error_code_enum<vcpkg::paragraph_parse_result> : ::std::true_type
    {
    };
}
