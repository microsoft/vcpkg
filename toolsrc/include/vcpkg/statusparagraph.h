#pragma once

#include <vcpkg/binaryparagraph.h>

#include <unordered_map>

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

    /// <summary>
    /// Installed package metadata
    /// </summary>
    struct StatusParagraph
    {
        StatusParagraph();
        explicit StatusParagraph(std::unordered_map<std::string, std::string>&& fields);

        BinaryParagraph package;
        Want want;
        InstallState state;
    };

    void serialize(const StatusParagraph& pgh, std::string& out_str);

    std::string to_string(InstallState f);

    std::string to_string(Want f);
}
