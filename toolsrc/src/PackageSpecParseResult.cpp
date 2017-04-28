#include "pch.h"

#include "PackageSpecParseResult.h"
#include "vcpkg_Checks.h"

namespace vcpkg
{
    const char* PackageSpecParseResultCategoryImpl::name() const noexcept { return "PackageSpecParseResult"; }

    std::string PackageSpecParseResultCategoryImpl::message(int ev) const noexcept
    {
        switch (static_cast<PackageSpecParseResult>(ev))
        {
            case PackageSpecParseResult::SUCCESS: return "OK";
            case PackageSpecParseResult::TOO_MANY_COLONS: return "Too many colons";
            case PackageSpecParseResult::INVALID_CHARACTERS:
                return "Contains invalid characters. Only alphanumeric lowercase ASCII characters and dashes are "
                       "allowed";
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    const std::error_category& package_spec_parse_result_category()
    {
        static PackageSpecParseResultCategoryImpl instance;
        return instance;
    }

    std::error_code make_error_code(PackageSpecParseResult e)
    {
        return std::error_code(static_cast<int>(e), package_spec_parse_result_category());
    }

    PackageSpecParseResult to_package_spec_parse_result(int i) { return static_cast<PackageSpecParseResult>(i); }

    PackageSpecParseResult to_package_spec_parse_result(std::error_code ec)
    {
        return to_package_spec_parse_result(ec.value());
    }
}
