#pragma once
#include <system_error>

namespace vcpkg
{
    enum class package_spec_parse_result
    {
        SUCCESS = 0,
        TOO_MANY_COLONS,
        INVALID_CHARACTERS
    };

    struct package_spec_parse_result_category_impl final : std::error_category
    {
        virtual const char* name() const noexcept override;

        virtual std::string message(int ev) const noexcept override;
    };

    const std::error_category& package_spec_parse_result_category();

    std::error_code make_error_code(package_spec_parse_result e);

    package_spec_parse_result to_package_spec_parse_result(int i);

    package_spec_parse_result to_package_spec_parse_result(std::error_code ec);
}

// Enable implicit conversion to std::error_code
namespace std
{
    template <>
    struct is_error_code_enum<vcpkg::package_spec_parse_result> : ::std::true_type
    {
    };
}
