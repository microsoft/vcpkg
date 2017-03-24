#include "pch.h"
#include "vcpkg_Checks.h"
#include "paragraph_parse_result.h"

namespace vcpkg
{
    const char* paragraph_parse_result_category_impl::name() const noexcept
    {
        return "paragraph_parse_result";
    }

    std::string paragraph_parse_result_category_impl::message(int ev) const noexcept
    {
        switch (static_cast<paragraph_parse_result>(ev))
        {
            case paragraph_parse_result::SUCCESS:
                return "OK";
            case paragraph_parse_result::EXPECTED_ONE_PARAGRAPH:
                return "There should be exactly one paragraph";
            default:
                Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    const std::error_category& paragraph_parse_result_category()
    {
        static paragraph_parse_result_category_impl instance;
        return instance;
    }

    std::error_code make_error_code(paragraph_parse_result e)
    {
        return std::error_code(static_cast<int>(e), paragraph_parse_result_category());
    }

    paragraph_parse_result to_paragraph_parse_result(int i)
    {
        return static_cast<paragraph_parse_result>(i);
    }

    paragraph_parse_result to_paragraph_parse_result(std::error_code ec)
    {
        return to_paragraph_parse_result(ec.value());
    }
}
