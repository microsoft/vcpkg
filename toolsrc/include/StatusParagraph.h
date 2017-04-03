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

    enum class Want
    {
        ERROR_STATE,
        UNKNOWN,
        INSTALL,
        HOLD,
        DEINSTALL,
        PURGE
    };

    struct StatusParagraph
    {
        StatusParagraph();
        explicit StatusParagraph(const std::unordered_map<std::string, std::string>& fields);

        BinaryParagraph package;
        Want want;
        InstallState state;
    };

    std::ostream& operator<<(std::ostream& os, const StatusParagraph& pgh);

    std::string to_string(InstallState f);

    std::string to_string(Want f);
}
