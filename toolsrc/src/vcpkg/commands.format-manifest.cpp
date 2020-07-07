#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/json.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/commands.h>
#include <vcpkg/portfileprovider.h>

namespace vcpkg::Commands::FormatManifest
{
    static constexpr StringLiteral OPTION_ALL = "--all";

    const CommandSwitch FORMAT_SWITCHES[] = {{OPTION_ALL, "Format all ports' manifest files."}};

    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string(R"###(x-format-manifest --all)###"),
        0,
        SIZE_MAX,
        {FORMAT_SWITCHES, {}, {}},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        auto parsed_args = args.parse_arguments(COMMAND_STRUCTURE);

        std::vector<fs::path> files_to_format;

        auto& fs = paths.get_filesystem();
        bool has_error = false;

        if (Util::Sets::contains(parsed_args.switches, OPTION_ALL))
        {
            for (const auto& dir : fs::directory_iterator(paths.ports))
            {
                auto manifest_path = dir.path() / fs::u8path("vcpkg.json");
                if (fs.exists(manifest_path))
                {
                    files_to_format.push_back(std::move(manifest_path));
                }
            }
        }

        for (const auto& arg : args.command_arguments)
        {
            auto path = fs::u8path(arg);
            if (path.is_relative())
            {
                path = paths.original_cwd / path;
            }
            files_to_format.push_back(std::move(path));
        }

        for (const auto& path : files_to_format)
        {
            std::error_code ec;
            Debug::print("Formatting ", path.u8string(), "\n");
            auto parsed_json_opt = Json::parse_file(fs, path, ec);
            if (ec)
            {
                System::printf(System::Color::error, "Failed to read %s: %s\n", path.u8string(), ec.message());
                has_error = true;
            }

            if (auto pr = parsed_json_opt.get())
            {
                fs.write_contents(path, Json::stringify(pr->first, Json::JsonStyle{}), ec);
            }
            else
            {
                System::printf(System::Color::error,
                               "Failed to parse %s: %s\n",
                               path.u8string(),
                               parsed_json_opt.error()->format());
                has_error = true;
            }

            if (ec)
            {
                System::printf(System::Color::error, "Failed to write %s: %s\n", path.u8string(), ec.message());
                has_error = true;
            }
        }

        if (has_error)
        {
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        else
        {
            System::print2("Succeeded in formatting the manifest files.\n");
            Checks::exit_success(VCPKG_LINE_INFO);
        }
    }
}
