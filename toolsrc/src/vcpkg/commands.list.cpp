#include "pch.h"

#include <vcpkg/base/system.print.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Commands::List
{
    static constexpr StringLiteral OPTION_FULLDESC =
        "--x-full-desc"; // TODO: This should find a better home, eventually

    static void do_print(const StatusParagraph& pgh, const bool full_desc)
    {
        if (full_desc)
        {
            System::printf("%-50s %-16s %s\n", pgh.package.displayname(), pgh.package.version, pgh.package.description);
        }
        else
        {
            System::printf("%-50s %-16s %s\n",
                           vcpkg::shorten_text(pgh.package.displayname(), 50),
                           vcpkg::shorten_text(pgh.package.version, 16),
                           vcpkg::shorten_text(pgh.package.description, 51));
        }
    }

    static constexpr std::array<CommandSwitch, 1> LIST_SWITCHES = {{
        {OPTION_FULLDESC, "Do not truncate long text"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format(
            "The argument should be a substring to search for, or no argument to display all installed libraries.\n%s",
            Help::create_example_string("list png")),
        0,
        1,
        {LIST_SWITCHES, {}},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        const StatusParagraphs status_paragraphs = database_load_check(paths);
        auto installed_ipv = get_installed_ports(status_paragraphs);

        if (installed_ipv.empty())
        {
            System::print2("No packages are installed. Did you mean `search`?\n");
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        auto installed_packages = Util::fmap(installed_ipv, [](const InstalledPackageView& ipv) { return ipv.core; });
        auto installed_features =
            Util::fmap_flatten(installed_ipv, [](const InstalledPackageView& ipv) { return ipv.features; });
        installed_packages.insert(installed_packages.end(), installed_features.begin(), installed_features.end());

        std::sort(installed_packages.begin(),
                  installed_packages.end(),
                  [](const StatusParagraph* lhs, const StatusParagraph* rhs) -> bool {
                      return lhs->package.displayname() < rhs->package.displayname();
                  });

        const auto enable_fulldesc = Util::Sets::contains(options.switches, OPTION_FULLDESC.to_string());

        if (args.command_arguments.empty())
        {
            for (const StatusParagraph* status_paragraph : installed_packages)
            {
                do_print(*status_paragraph, enable_fulldesc);
            }
        }
        else
        {
            // At this point there is 1 argument
            for (const StatusParagraph* status_paragraph : installed_packages)
            {
                const std::string displayname = status_paragraph->package.displayname();
                if (!Strings::case_insensitive_ascii_contains(displayname, args.command_arguments[0]))
                {
                    continue;
                }

                do_print(*status_paragraph, enable_fulldesc);
            }
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
