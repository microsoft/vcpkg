#include "pch.h"
#include "StatusParagraph.h"
#include "vcpkglib_helpers.h"

using namespace vcpkg::details;

namespace vcpkg
{
    //
    namespace BinaryParagraphRequiredField
    {
        static const std::string STATUS = "Status";
    }

    StatusParagraph::StatusParagraph() : want(Want::error), state(InstallState::ERROR_STATE)
    {
    }

    std::ostream& operator<<(std::ostream& os, const StatusParagraph& p)
    {
        os << p.package;
        os << "Status: " << to_string(p.want) << " ok " << to_string(p.state) << "\n";
        return os;
    }

    StatusParagraph::StatusParagraph(const std::unordered_map<std::string, std::string>& fields)
        : package(fields)
    {
        std::string status_field = required_field(fields, BinaryParagraphRequiredField::STATUS);

        auto b = status_field.begin();
        auto mark = b;
        auto e = status_field.end();

        // Todo: improve error handling
        while (b != e && *b != ' ')
            ++b;

        want = [](const std::string& text)
            {
                if (text == "unknown")
                    return Want::unknown;
                if (text == "install")
                    return Want::install;
                if (text == "hold")
                    return Want::hold;
                if (text == "deinstall")
                    return Want::deinstall;
                if (text == "purge")
                    return Want::purge;
                return Want::error;
            }(std::string(mark, b));

        if (std::distance(b, e) < 4)
            return;
        b += 4;

        state = [](const std::string& text)
            {
                if (text == "not-installed")
                    return InstallState::NOT_INSTALLED;
                if (text == "installed")
                    return InstallState::INSTALLED;
                if (text == "half-installed")
                    return InstallState::HALF_INSTALLED;
                return InstallState::ERROR_STATE;
            }(std::string(b, e));
    }

    std::string to_string(InstallState f)
    {
        switch (f)
        {
            case InstallState::HALF_INSTALLED: return "half-installed";
            case InstallState::INSTALLED: return "installed";
            case InstallState::NOT_INSTALLED: return "not-installed";
            default: return "error";
        }
    }

    std::string to_string(Want f)
    {
        switch (f)
        {
            case Want::deinstall: return "deinstall";
            case Want::hold: return "hold";
            case Want::install: return "install";
            case Want::purge: return "purge";
            case Want::unknown: return "unknown";
            default: return "error";
        }
    }
}
