#pragma once

#include "vcpkg_expected.h"

namespace vcpkg
{
    enum class PackageSpecParseResult
    {
        SUCCESS = 0,
        TOO_MANY_COLONS,
        INVALID_CHARACTERS
    };

    CStringView to_string(PackageSpecParseResult ev) noexcept;

    template<>
    struct ErrorHolder<PackageSpecParseResult>
    {
        ErrorHolder() : m_err(PackageSpecParseResult::SUCCESS) {}
        ErrorHolder(PackageSpecParseResult err) : m_err(err) {}

        constexpr bool has_error() const { return m_err != PackageSpecParseResult::SUCCESS; }

        PackageSpecParseResult error() const { return m_err; }

        CStringView to_string() const { return vcpkg::to_string(m_err); }

    private:
        PackageSpecParseResult m_err;
    };
}
