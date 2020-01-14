#pragma once

#include <vcpkg/base/cstringview.h>
#include <vcpkg/base/expected.h>

namespace vcpkg
{
    enum class PackageSpecParseResult
    {
        SUCCESS = 0,
        TOO_MANY_COLONS,
        INVALID_CHARACTERS
    };

    void to_string(std::string& out, ::vcpkg::PackageSpecParseResult p);

    CStringView to_string(PackageSpecParseResult ev) noexcept;

    template<>
    struct ErrorHolder<PackageSpecParseResult>
    {
        ErrorHolder() noexcept : m_err(PackageSpecParseResult::SUCCESS) {}
        ErrorHolder(PackageSpecParseResult err) : m_err(err) {}

        bool has_error() const { return m_err != PackageSpecParseResult::SUCCESS; }

        const PackageSpecParseResult& error() const { return m_err; }
        PackageSpecParseResult& error() { return m_err; }

        CStringView to_string() const { return vcpkg::to_string(m_err); }

    private:
        PackageSpecParseResult m_err;
    };
}
