#include "pch.h"

#include "StatusParagraph.h"

using namespace vcpkg::Parse;

namespace vcpkg
{
    namespace BinaryParagraphRequiredField
    {
        static const std::string STATUS = "Status";
    }

    StatusParagraph::StatusParagraph() : want(Want::ERROR_STATE), state(InstallState::ERROR_STATE) {}

    void serialize(const StatusParagraph& pgh, std::string& out_str)
    {
        serialize(pgh.package, out_str);
        out_str.append("Status: ")
            .append(to_string(pgh.want))
            .append(" ok ")
            .append(to_string(pgh.state))
            .push_back('\n');
    }

    StatusParagraph::StatusParagraph(std::unordered_map<std::string, std::string>&& fields)
    {
        auto status_it = fields.find(BinaryParagraphRequiredField::STATUS);
        Checks::check_exit(VCPKG_LINE_INFO, status_it != fields.end(), "Expected 'Status' field in status paragraph");
        std::string status_field = std::move(status_it->second);
        fields.erase(status_it);

        this->package = BinaryParagraph(std::move(fields));

        auto b = status_field.begin();
        const auto mark = b;
        const auto e = status_field.end();

        // Todo: improve error handling
        while (b != e && *b != ' ')
            ++b;

        want = [](const std::string& text) {
            if (text == "unknown") return Want::UNKNOWN;
            if (text == "install") return Want::INSTALL;
            if (text == "hold") return Want::HOLD;
            if (text == "deinstall") return Want::DEINSTALL;
            if (text == "purge") return Want::PURGE;
            return Want::ERROR_STATE;
        }(std::string(mark, b));

        if (std::distance(b, e) < 4) return;
        b += 4;

        state = [](const std::string& text) {
            if (text == "not-installed") return InstallState::NOT_INSTALLED;
            if (text == "installed") return InstallState::INSTALLED;
            if (text == "half-installed") return InstallState::HALF_INSTALLED;
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
            case Want::DEINSTALL: return "deinstall";
            case Want::HOLD: return "hold";
            case Want::INSTALL: return "install";
            case Want::PURGE: return "purge";
            case Want::UNKNOWN: return "unknown";
            default: return "error";
        }
    }
}
