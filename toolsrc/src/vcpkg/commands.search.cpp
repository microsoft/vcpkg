#include <vcpkg/base/system.print.h>

#include <vcpkg/commands.search.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/sourceparagraph.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkglib.h>
#include <vcpkg/versiont.h>

using vcpkg::PortFileProvider::PathsPortFileProvider;

namespace vcpkg::Commands::Search
{
    static constexpr StringLiteral OPTION_FULLDESC = "x-full-desc"; // TODO: This should find a better home, eventually
    static constexpr StringLiteral OPTION_JSON = "x-json";

    static void do_print_json(std::vector<const vcpkg::SourceControlFile*> source_control_files)
    {
        Json::Object obj;
        for (const SourceControlFile* scf : source_control_files)
        {
            auto& source_paragraph = scf->core_paragraph;
            Json::Object& library_obj = obj.insert(source_paragraph->name, Json::Object());
            library_obj.insert("package_name", Json::Value::string(source_paragraph->name));
            library_obj.insert("version", Json::Value::string(source_paragraph->version));
            library_obj.insert("port_version", Json::Value::integer(source_paragraph->port_version));
            Json::Array& desc = library_obj.insert("description", Json::Array());
            for (const auto& line : source_paragraph->description)
            {
                desc.push_back(Json::Value::string(line));
            }
        }

        System::print2(Json::stringify(obj, Json::JsonStyle{}));
    }
    static void do_print(const SourceParagraph& source_paragraph, bool full_desc)
    {
        auto full_version = VersionT(source_paragraph.version, source_paragraph.port_version).to_string();
        if (full_desc)
        {
            System::printf("%-20s %-16s %s\n",
                           source_paragraph.name,
                           full_version,
                           Strings::join("\n    ", source_paragraph.description));
        }
        else
        {
            std::string description;
            if (!source_paragraph.description.empty())
            {
                description = source_paragraph.description[0];
            }
            System::printf("%-20s %-16s %s\n",
                           vcpkg::shorten_text(source_paragraph.name, 20),
                           vcpkg::shorten_text(full_version, 16),
                           vcpkg::shorten_text(description, 81));
        }
    }

    static void do_print(const std::string& name, const FeatureParagraph& feature_paragraph, bool full_desc)
    {
        auto full_feature_name = Strings::concat(name, "[", feature_paragraph.name, "]");
        if (full_desc)
        {
            System::printf("%-37s %s\n", full_feature_name, Strings::join("\n   ", feature_paragraph.description));
        }
        else
        {
            std::string description;
            if (!feature_paragraph.description.empty())
            {
                description = feature_paragraph.description[0];
            }
            System::printf(
                "%-37s %s\n", vcpkg::shorten_text(full_feature_name, 37), vcpkg::shorten_text(description, 81));
        }
    }

    static constexpr std::array<CommandSwitch, 2> SEARCH_SWITCHES = {{
        {OPTION_FULLDESC, "Do not truncate long text"},
        {OPTION_JSON, "(experimental) List libraries in JSON format"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format(
            "The argument should be a substring to search for, or no argument to display all libraries.\n%s",
            create_example_string("search png")),
        0,
        1,
        {SEARCH_SWITCHES, {}},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);
        const bool full_description = Util::Sets::contains(options.switches, OPTION_FULLDESC);
        const bool enable_json = Util::Sets::contains(options.switches, OPTION_JSON);

        PathsPortFileProvider provider(paths, args.overlay_ports);
        auto source_paragraphs =
            Util::fmap(provider.load_all_control_files(),
                       [](auto&& port) -> const SourceControlFile* { return port->source_control_file.get(); });

        if (args.command_arguments.empty())
        {
            if (enable_json)
            {
                do_print_json(source_paragraphs);
            }
            else
            {
                for (const auto& source_control_file : source_paragraphs)
                {
                    do_print(*source_control_file->core_paragraph, full_description);
                    for (auto&& feature_paragraph : source_control_file->feature_paragraphs)
                    {
                        do_print(source_control_file->core_paragraph->name, *feature_paragraph, full_description);
                    }
                }
            }
        }
        else
        {
            // At this point there is 1 argument
            auto&& args_zero = args.command_arguments[0];
            const auto contained_in = [&args_zero](const auto& s) {
                return Strings::case_insensitive_ascii_contains(s, args_zero);
            };
            for (const auto& source_control_file : source_paragraphs)
            {
                auto&& sp = *source_control_file->core_paragraph;

                bool found_match = contained_in(sp.name);
                if (!found_match)
                {
                    found_match = std::any_of(sp.description.begin(), sp.description.end(), contained_in);
                }

                if (found_match)
                {
                    do_print(sp, full_description);
                }

                for (auto&& feature_paragraph : source_control_file->feature_paragraphs)
                {
                    bool found_match_for_feature = found_match;
                    if (!found_match_for_feature)
                    {
                        found_match_for_feature = contained_in(feature_paragraph->name);
                    }
                    if (!found_match_for_feature)
                    {
                        found_match_for_feature = std::any_of(
                            feature_paragraph->description.begin(), feature_paragraph->description.end(), contained_in);
                    }

                    if (found_match_for_feature)
                    {
                        do_print(sp.name, *feature_paragraph, full_description);
                    }
                }
            }
        }

        if (!enable_json)
        {
            System::print2(
                "\nIf your library is not listed, please open an issue at and/or consider making a pull request:\n"
                "    https://github.com/Microsoft/vcpkg/issues\n");
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void SearchCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        Search::perform_and_exit(args, paths);
    }
}
