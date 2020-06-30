#include "pch.h"

#include <vcpkg/base/system.print.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/vcpkglib.h>
#include <vcpkg/base/json.h>

namespace vcpkg::Commands::List
{
    static constexpr StringLiteral OPTION_FULLDESC =
        "--x-full-desc"; // TODO: This should find a better home, eventually

    static constexpr StringLiteral OPTION_JSON = "--json";

    static void do_print_json(std::vector<const vcpkg::StatusParagraph*> installed_packages) {
        Json::Object& obj = Json::Object();

        for (const StatusParagraph* status_paragraph : installed_packages) {
            auto current_spec = status_paragraph->package.spec;
            if(!obj.contains(current_spec.name())) {
                Json::Object& library_obj = obj.insert(current_spec.name(), Json::Object());
                library_obj.insert("package_name", Json::Value::string(current_spec.name()));
                library_obj.insert("triplet", Json::Value::string(current_spec.triplet().to_string()));
                library_obj.insert("version", Json::Value::string(status_paragraph->package.version));
                Json::Array& arr = Json::Array();
                if(status_paragraph->package.is_feature()) {
                    arr.push_back(Json::Value::string(status_paragraph->package.feature));
                }
                library_obj.insert("feature", Json::Value::array(std::move(arr)));
                library_obj.insert("desc", Json::Value::string(Strings::join("\n    ", status_paragraph->package.description)));
            } else {
                if(status_paragraph->package.is_feature()) {
                    auto library_obj =  obj.get(current_spec.name());
                    auto& feature_list = library_obj->object().get("feature")->array();
                    feature_list.push_back(Json::Value::string(status_paragraph->package.feature));
                }
            }
        }

        System::printf("%s\n", Json::stringify(obj, Json::JsonStyle{}));
    }

    static void do_print(const StatusParagraph& pgh, const bool full_desc)
    {
        if (full_desc)
        {
            System::printf("%-50s %-16s %s\n",
                           pgh.package.displayname(),
                           pgh.package.version,
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
                           vcpkg::shorten_text(pgh.package.version, 16),
                           vcpkg::shorten_text(description, 51));
        }
    }

    static constexpr std::array<CommandSwitch, 2> LIST_SWITCHES = {{
        {OPTION_FULLDESC, "Do not truncate long text"},
        {OPTION_JSON, "List libraries in JSON format"}
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
        const auto enable_json = Util::Sets::contains(options.switches, OPTION_JSON.to_string());

        if (args.command_arguments.empty())
        {
            if(enable_json) {
                do_print_json(installed_packages);
            } else {
                for (const StatusParagraph* status_paragraph : installed_packages)
                {
                    do_print(*status_paragraph, enable_fulldesc);
                }
            }
        }
        else
        {
            // At this point there is 1 argument

            if(enable_json) {
                auto& query = args.command_arguments[0];
                auto pghs = Util::filter(installed_packages, [query](const StatusParagraph* status_paragraph) {
                    return Strings::case_insensitive_ascii_contains(status_paragraph->package.displayname(), query);
                });
                do_print_json(pghs);
            } else {
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
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
