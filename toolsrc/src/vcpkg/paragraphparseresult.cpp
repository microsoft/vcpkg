#include "pch.h"

#include <vcpkg/base/checks.h>

#include <vcpkg/paragraphparseresult.h>

namespace vcpkg
{
    const char* ParagraphParseResultCategoryImpl::name() const noexcept { return "ParagraphParseResult"; }

    std::string ParagraphParseResultCategoryImpl::message(int ev) const noexcept
    {
        switch (static_cast<ParagraphParseResult>(ev))
        {
            case ParagraphParseResult::SUCCESS: return "OK";
            case ParagraphParseResult::EXPECTED_ONE_PARAGRAPH: return "There should be exactly one paragraph";
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    const std::error_category& paragraph_parse_result_category()
    {
        static ParagraphParseResultCategoryImpl instance;
        return instance;
    }

    std::error_code make_error_code(ParagraphParseResult e)
    {
        return std::error_code(static_cast<int>(e), paragraph_parse_result_category());
    }

    ParagraphParseResult to_paragraph_parse_result(int i) { return static_cast<ParagraphParseResult>(i); }

    ParagraphParseResult to_paragraph_parse_result(std::error_code ec) { return to_paragraph_parse_result(ec.value()); }
}
