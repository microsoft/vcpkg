#pragma once

#include <unordered_map>
#include "BinaryParagraph.h"

namespace vcpkg
{
    enum class install_state_t
    {
        error,
        not_installed,
        half_installed,
        installed,
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
        install_state_t state;
    };

    std::ostream& operator<<(std::ostream& os, const StatusParagraph& pgh);

    std::string to_string(install_state_t f);

    std::string to_string(want_t f);
}
