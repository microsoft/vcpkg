#include "pch.h"

#include <vcpkg/base/json.h>
#include <vcpkg/base/parse.h>
#include <vcpkg/base/stringliteral.h>

#include <vcpkg/commands.info.h>
#include <vcpkg/input.h>
#include <vcpkg/install.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/statusparagraphs.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkglib.h>
#include <vcpkg/versiont.h>

namespace vcpkg::Commands::Info
{
    static constexpr StringLiteral OPTION_TRANSITIVE = "x-transitive";
    static constexpr StringLiteral OPTION_INSTALLED = "x-installed";

    static constexpr CommandSwitch INFO_SWITCHES[] = {
        {OPTION_INSTALLED, "(experimental) Report on installed packages instead of available"},
        {OPTION_TRANSITIVE, "(experimental) Also report on dependencies of installed packages"},
    };

    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format("Display detailed information on packages.\n%s",
                        create_example_string("x-package-info zlib openssl:x64-windows")),
        1,
        SIZE_MAX,
        {INFO_SWITCHES, {}},
        nullptr,
    };

    void InfoCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);
        if (!args.output_json())
        {
            Checks::exit_with_message(
                VCPKG_LINE_INFO, "This command currently requires --%s", VcpkgCmdArguments::JSON_SWITCH);
        }

        const bool installed = Util::Sets::contains(options.switches, OPTION_INSTALLED);
        const bool transitive = Util::Sets::contains(options.switches, OPTION_TRANSITIVE);

        if (transitive && !installed)
        {
            Checks::exit_with_message(VCPKG_LINE_INFO, "--%s requires --%s", OPTION_TRANSITIVE, OPTION_INSTALLED);
        }

        if (installed)
        {
            const StatusParagraphs status_paragraphs = database_load_check(paths);
            std::set<PackageSpec> specs_written;
            std::vector<PackageSpec> specs_to_write;
            for (auto&& arg : args.command_arguments)
            {
                Parse::ParserBase parser(arg, "<command>");
                auto maybe_qpkg = parse_qualified_specifier(parser);
                if (!parser.at_eof() || !maybe_qpkg)
                {
                    parser.add_error("expected a package specifier");
                }
                else if (!maybe_qpkg.get()->triplet)
                {
                    parser.add_error("expected an explicit triplet");
                }
                else if (maybe_qpkg.get()->features)
                {
                    parser.add_error("unexpected list of features");
                }
                else if (maybe_qpkg.get()->platform)
                {
                    parser.add_error("unexpected qualifier");
                }
                if (auto err = parser.get_error())
                {
                    System::print2(err->format(), "\n");
                    Checks::exit_fail(VCPKG_LINE_INFO);
                }

                auto& qpkg = *maybe_qpkg.get();
                auto t = Triplet::from_canonical_name(std::string(*qpkg.triplet.get()));
                Input::check_triplet(t, paths);
                specs_to_write.emplace_back(qpkg.name, t);
            }
            Json::Object response;
            Json::Object results;
            while (!specs_to_write.empty())
            {
                auto spec = std::move(specs_to_write.back());
                specs_to_write.pop_back();
                if (!specs_written.insert(spec).second) continue;
                auto maybe_ipv = status_paragraphs.get_installed_package_view(spec);
                if (auto ipv = maybe_ipv.get())
                {
                    results.insert(spec.to_string(), serialize_ipv(*ipv, paths));
                    if (transitive)
                    {
                        auto deps = ipv->dependencies();
                        specs_to_write.insert(specs_to_write.end(),
                                              std::make_move_iterator(deps.begin()),
                                              std::make_move_iterator(deps.end()));
                    }
                }
            }
            response.insert("results", std::move(results));
            System::print2(Json::stringify(response, {}));
        }
        else
        {
            Json::Object response;
            Json::Object results;
            PortFileProvider::PathsPortFileProvider provider(paths, args.overlay_ports);

            for (auto&& arg : args.command_arguments)
            {
                Parse::ParserBase parser(arg, "<command>");
                auto maybe_pkg = parse_package_name(parser);
                if (!parser.at_eof() || !maybe_pkg)
                {
                    parser.add_error("expected only a package identifier");
                }
                if (auto err = parser.get_error())
                {
                    System::print2(err->format(), "\n");
                    Checks::exit_fail(VCPKG_LINE_INFO);
                }

                auto& pkg = *maybe_pkg.get();

                if (results.contains(pkg)) continue;

                auto maybe_scfl = provider.get_control_file(pkg);

                Json::Object obj;
                if (auto pscfl = maybe_scfl.get())
                {
                    results.insert(pkg, serialize_manifest(*pscfl->source_control_file));
                }
            }
            response.insert("results", std::move(results));
            System::print2(Json::stringify(response, {}));
        }
    }
}
