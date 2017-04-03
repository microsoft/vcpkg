#pragma once

#include <unordered_map>
#include "BinaryParagraph.h"

namespace vcpkg
{
    enum class InstallState
    {
        ERROR_STATE,
        NOT_INSTALLED,
        HALF_INSTALLED,
        INSTALLED,
    };

    enum class want_t
    {
        error,
        unknown,
        install,
        hold,
        deinstall,
        purge
    };

    struct StatusParagraph
    {
        StatusParagraph();
        explicit StatusParagraph(const std::unordered_map<std::string, std::string>& fields);

        BinaryParagraph package;
        want_t want;
        InstallState state;
    };

    std::ostream& operator<<(std::ostream& os, const StatusParagraph& pgh);

    std::string to_string(InstallState f);

    std::string to_string(want_t f);
}
