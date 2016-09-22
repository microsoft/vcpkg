#include "vcpkg_Commands.h"
#include "vcpkg.h"
#include <fstream>
#include "vcpkg_Environment.h"
#include "metrics.h"
#include "vcpkg_Files.h"
#include "post_build_lint.h"
#include "vcpkg_System.h"

namespace vcpkg
{
    static void create_binary_control_file(const vcpkg_paths& paths, const fs::path& port_dir, const triplet& target_triplet)
    {
        auto pghs = get_paragraphs(port_dir / "CONTROL");
        Checks::check_exit(pghs.size() == 1, "Error: invalid control file");
        auto bpgh = BinaryParagraph(SourceParagraph(pghs[0]), target_triplet);
        const fs::path binary_control_file = paths.packages / bpgh.dir() / "CONTROL";
        std::ofstream(binary_control_file) << bpgh;
    }

    static void build_internal(const package_spec& spec, const vcpkg_paths& paths, const fs::path& port_dir)
    {
        const fs::path ports_cmake_script_path = paths.ports_cmake;
        const std::wstring command = Strings::format(LR"("%%VS140COMNTOOLS%%..\..\VC\vcvarsall.bat" %s && cmake -DCMD=BUILD -DPORT=%s -DTARGET_TRIPLET=%s "-DCURRENT_PORT_DIR=%s/." -P "%s")",
                                                     Strings::utf8_to_utf16(spec.target_triplet.architecture()),
                                                     Strings::utf8_to_utf16(spec.name),
                                                     Strings::utf8_to_utf16(spec.target_triplet.value),
                                                     port_dir.generic_wstring(),
                                                     ports_cmake_script_path.generic_wstring());

        System::Stopwatch timer;
        timer.start();
        int return_code = System::cmd_execute(command);
        timer.stop();
        TrackMetric("buildtimeus-" + to_string(spec), timer.microseconds());

        if (return_code != 0)
        {
            System::println(System::color::error, "Error: build command failed");
            TrackProperty("error", "build failed");
            TrackProperty("build_error", std::to_string(return_code));
            exit(EXIT_FAILURE);
        }

        perform_all_checks(spec, paths);

        create_binary_control_file(paths, port_dir, spec.target_triplet);

        // const fs::path port_buildtrees_dir = paths.buildtrees / spec.name;
        // delete_directory(port_buildtrees_dir);
    }

    static void build_internal(const package_spec& spec, const vcpkg_paths& paths)
    {
        return build_internal(spec, paths, paths.ports / spec.name);
    }

    void install_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet)
    {
        StatusParagraphs status_db = database_load_check(paths);

        std::vector<package_spec> specs = args.extract_package_specs_with_unmet_dependencies(paths, default_target_triplet, status_db);
        Checks::check_exit(!specs.empty(), "Specs cannot be empty");
        std::string specs_string = to_string(specs[0]);
        for (size_t i = 1; i < specs.size(); ++i)
        {
            specs_string.push_back(',');
            specs_string.append(to_string(specs[i]));
        }
        TrackProperty("installplan", specs_string);
        Environment::ensure_utilities_on_path(paths);

        for (const package_spec& spec : specs)
        {
            if (status_db.find_installed(spec.name, spec.target_triplet) != status_db.end())
            {
                System::println(System::color::success, "Package %s is already installed", spec);
                continue;
            }

            fs::path package_path = find_available_package(paths, spec);

            expected<std::string> file_contents = Files::get_contents(package_path / "CONTROL");

            try
            {
                if (file_contents.error_code())
                {
                    build_internal(spec, paths);
                    file_contents = Files::get_contents(package_path / "CONTROL");
                    if (file_contents.error_code())
                    {
                        file_contents.get_or_throw();
                    }
                }

                auto pghs = parse_paragraphs(file_contents.get_or_throw());
                Checks::check_throw(pghs.size() == 1, "multiple paragraphs in control file");
                install_package(paths, BinaryParagraph(pghs[0]), status_db);
                System::println(System::color::success, "Package %s is installed", spec);
            }
            catch (const std::exception& e)
            {
                System::println(System::color::error, "Error: Could not install package %s: %s", spec, e.what());
                exit(EXIT_FAILURE);
            }
        }

        exit(EXIT_SUCCESS);
    }

    void build_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet)
    {
        std::vector<package_spec> specs = args.parse_all_arguments_as_package_specs(default_target_triplet);
        Environment::ensure_utilities_on_path(paths);
        for (const package_spec& spec : specs)
        {
            build_internal(spec, paths);
        }
        exit(EXIT_SUCCESS);
    }

    void build_external_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet)
    {
        if (args.command_arguments.size() != 2)
        {
            System::println(System::color::error, "Error: buildexternal requires the package name and the directory containing the CONTROL file");
            print_example(R"(buildexternal mylib C:\path\to\mylib\)");
            exit(EXIT_FAILURE);
        }

        expected<package_spec> current_spec = vcpkg::parse(args.command_arguments[0], default_target_triplet);
        if (auto spec = current_spec.get())
        {
            Environment::ensure_utilities_on_path(paths);
            const fs::path port_dir = args.command_arguments.at(1);
            build_internal(*spec, paths, port_dir);
            exit(EXIT_SUCCESS);
        }

        System::println(System::color::error, "Error: %s: %s", current_spec.error_code().message(), args.command_arguments[0]);
        print_example(Strings::format("%s zlib:x64-windows", args.command).c_str());
        exit(EXIT_FAILURE);
    }
}
