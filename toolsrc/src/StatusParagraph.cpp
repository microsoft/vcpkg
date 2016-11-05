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

    StatusParagraph::StatusParagraph() : want(want_t::error), state(install_state_t::error)
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
                    return want_t::unknown;
                if (text == "install")
                    return want_t::install;
                if (text == "hold")
                    return want_t::hold;
                if (text == "deinstall")
                    return want_t::deinstall;
                if (text == "purge")
                    return want_t::purge;
                return want_t::error;
            }(std::string(mark, b));

        if (std::distance(b, e) < 4)
            return;
        b += 4;

        state = [](const std::string& text)
            {
                if (text == "not-installed")
                    return install_state_t::not_installed;
                if (text == "installed")
                    return install_state_t::installed;
                if (text == "half-installed")
                    return install_state_t::half_installed;
                return install_state_t::error;
            }(std::string(b, e));
    }

    std::string to_string(install_state_t f)
    {
        switch (f)
        {
            case install_state_t::half_installed: return "half-installed";
            case install_state_t::installed: return "installed";
            case install_state_t::not_installed: return "not-installed";
            default: return "error";
        }
    }

    std::string to_string(want_t f)
    {
        switch (f)
        {
            case want_t::deinstall: return "deinstall";
            case want_t::hold: return "hold";
            case want_t::install: return "install";
            case want_t::purge: return "purge";
            case want_t::unknown: return "unknown";
            default: return "error";
        }
    }
}
