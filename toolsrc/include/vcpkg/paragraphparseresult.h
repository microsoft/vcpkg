#pragma once

#include <system_error>

namespace vcpkg
{
    enum class ParagraphParseResult
    {
        SUCCESS = 0,
        EXPECTED_ONE_PARAGRAPH
    };

    struct ParagraphParseResultCategoryImpl final : std::error_category
    {
        virtual const char* name() const noexcept override;

        virtual std::string message(int ev) const noexcept override;
    };

    const std::error_category& paragraph_parse_result_category();

    std::error_code make_error_code(ParagraphParseResult e);

    ParagraphParseResult to_paragraph_parse_result(int i);

    ParagraphParseResult to_paragraph_parse_result(std::error_code ec);
}

namespace std
{
    // Enable implicit conversion to std::error_code
    template<>
    struct is_error_code_enum<vcpkg::ParagraphParseResult> : ::std::true_type
    {
    };
}