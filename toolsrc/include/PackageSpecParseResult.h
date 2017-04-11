#pragma once
#include <system_error>

namespace vcpkg
{
    enum class PackageSpecParseResult
    {
        SUCCESS = 0,
        TOO_MANY_COLONS,
        INVALID_CHARACTERS
    };

    struct PackageSpecParseResultCategoryImpl final : std::error_category
    {
        virtual const char* name() const noexcept override;

        virtual std::string message(int ev) const noexcept override;
    };

    const std::error_category& package_spec_parse_result_category();

    std::error_code make_error_code(PackageSpecParseResult e);

    PackageSpecParseResult to_package_spec_parse_result(int i);

    PackageSpecParseResult to_package_spec_parse_result(std::error_code ec);
}

// Enable implicit conversion to std::error_code
namespace std
{
    template <>
    struct is_error_code_enum<vcpkg::PackageSpecParseResult> : ::std::true_type
    {
    };
}
