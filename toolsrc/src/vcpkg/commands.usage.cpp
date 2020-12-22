#include <vcpkg/commands.usage.h>
#include <vcpkg/input.h>
#include <vcpkg/install.h>
#include <vcpkg/statusparagraphs.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Commands::Usage
{
    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format("Display usage information for installed packages.\n%s",
                        create_example_string("x-usage zlib openssl")),
        1,
        SIZE_MAX,
        {},
        nullptr,
    };

    void UsageCommand::perform_and_exit(const VcpkgCmdArguments& args,
                                        const VcpkgPaths& paths,
                                        Triplet default_triplet) const
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        const std::vector<FullPackageSpec> specs = Util::fmap(args.command_arguments, [&](auto&& arg) {
            return Input::check_and_get_full_package_spec(
                std::string(arg), default_triplet, COMMAND_STRUCTURE.example_text);
        });

        const StatusParagraphs status_paragraphs = database_load_check(paths);

        std::set<std::string> not_installed;
        for (auto&& spec : specs)
        {
            auto maybe_ipv = status_paragraphs.get_installed_package_view(spec.package_spec);
            if (vcpkg::InstalledPackageView* ipv = maybe_ipv.get())
            {
                auto&& usage_info = Install::get_cmake_usage(ipv->core->package, paths);

                if (!usage_info.message.empty())
                {
                    System::print2(usage_info.message);
                }
            }
            else
            {
                not_installed.emplace(spec.package_spec.to_string());
            }
        }

        for (auto&& package : not_installed)
        {
            System::printf(System::Color::error, "Package %s is not installed.\n", package);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
