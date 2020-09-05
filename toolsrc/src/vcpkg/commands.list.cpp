#include <vcpkg/base/system.print.h>

#include <vcpkg/commands.list.h>
#include <vcpkg/help.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkglib.h>
#include <vcpkg/versiont.h>

namespace vcpkg::Commands::List
{
    static constexpr StringLiteral OPTION_FULLDESC = "x-full-desc"; // TODO: This should find a better home, eventually

    static void do_print_json(std::vector<const vcpkg::StatusParagraph*> installed_packages)
    {
        Json::Object obj;
        for (const StatusParagraph* status_paragraph : installed_packages)
        {
            auto current_spec = status_paragraph->package.spec;
            if (obj.contains(current_spec.to_string()))
            {
                if (status_paragraph->package.is_feature())
                {
                    Json::Value* value_obj = obj.get(current_spec.to_string());
                    auto& feature_list = value_obj->object()["features"].array();
                    feature_list.push_back(Json::Value::string(status_paragraph->package.feature));
                }
            }
            else
            {
                Json::Object& library_obj = obj.insert(current_spec.to_string(), Json::Object());
                library_obj.insert("package_name", Json::Value::string(current_spec.name()));
                library_obj.insert("triplet", Json::Value::string(current_spec.triplet().to_string()));
                library_obj.insert("version", Json::Value::string(status_paragraph->package.version));
                library_obj.insert("port_version", Json::Value::integer(status_paragraph->package.port_version));
                Json::Array& features_array = library_obj.insert("features", Json::Array());
                if (status_paragraph->package.is_feature())
                {
                    features_array.push_back(Json::Value::string(status_paragraph->package.feature));
                }
                Json::Array& desc = library_obj.insert("desc", Json::Array());
                for (const auto& line : status_paragraph->package.description)
                {
                    desc.push_back(Json::Value::string(line));
                }
            }
        }

        System::print2(Json::stringify(obj, Json::JsonStyle{}));
    }

    static void do_print(const StatusParagraph& pgh, const bool full_desc)
    {
        auto full_version = VersionT(pgh.package.version, pgh.package.port_version).to_string();
        if (full_desc)
        {
            System::printf("%-50s %-16s %s\n",
                           pgh.package.displayname(),
                           full_version,
                           Strings::join("\n    ", pgh.package.description));
        }
        else
        {
            std::string description;
            if (!pgh.package.description.empty())
            {
                description = pgh.package.description[0];
            }
            System::printf("%-50s %-16s %s\n",
                           vcpkg::shorten_text(pgh.package.displayname(), 50),
                           vcpkg::shorten_text(full_version, 16),
                           vcpkg::shorten_text(description, 51));
        }
    }

    static constexpr std::array<CommandSwitch, 1> LIST_SWITCHES = {{
        {OPTION_FULLDESC, "Do not truncate long text"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format(
            "The argument should be a substring to search for, or no argument to display all installed libraries.\n%s",
            create_example_string("list png")),
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

        if (!args.command_arguments.empty())
        {
            auto& query = args.command_arguments[0];
            auto pghs = Util::filter(installed_packages, [query](const StatusParagraph* status_paragraph) {
                return Strings::case_insensitive_ascii_contains(status_paragraph->package.displayname(), query);
            });
            installed_packages = pghs;
        }

        if (args.output_json())
        {
            do_print_json(installed_packages);
        }
        else
        {
            for (const StatusParagraph* status_paragraph : installed_packages)
            {
                do_print(*status_paragraph, enable_fulldesc);
            }
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void ListCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        List::perform_and_exit(args, paths);
    }
}
