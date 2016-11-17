#include "vcpkg_Commands.h"
#include "vcpkg.h"
#include <fstream>
#include "vcpkg_Environment.h"
#include "metrics.h"
#include "vcpkg_Files.h"
#include "post_build_lint.h"
#include "vcpkg_System.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Input.h"
#include "vcpkg_Maps.h"
#include "vcpkg_info.h"

namespace vcpkg
{
    using Dependencies::package_spec_with_install_plan;
    using Dependencies::install_plan_type;

    static const std::string OPTION_CHECKS_ONLY = "--checks-only";

    static void create_binary_control_file(const vcpkg_paths& paths, const SourceParagraph& source_paragraph, const triplet& target_triplet)
    {
        const BinaryParagraph bpgh = BinaryParagraph(source_paragraph, target_triplet);
        const fs::path binary_control_file = paths.packages / bpgh.dir() / "CONTROL";
        std::ofstream(binary_control_file) << bpgh;
    }

    static void build_internal(const SourceParagraph& source_paragraph, const package_spec& spec, const vcpkg_paths& paths, const fs::path& port_dir)
    {
        Checks::check_exit(spec.name() == source_paragraph.name, "inconsistent arguments to build_internal()");
        const triplet& target_triplet = spec.target_triplet();

        const fs::path ports_cmake_script_path = paths.ports_cmake;
        const std::wstring command = Strings::wformat(LR"("%%VS140COMNTOOLS%%..\..\VC\vcvarsall.bat" %s && cmake -DCMD=BUILD -DPORT=%s -DTARGET_TRIPLET=%s "-DCURRENT_PORT_DIR=%s/." -P "%s")",
                                                      Strings::utf8_to_utf16(target_triplet.architecture()),
                                                      Strings::utf8_to_utf16(source_paragraph.name),
                                                      Strings::utf8_to_utf16(target_triplet.canonical_name()),
                                                      port_dir.generic_wstring(),
                                                      ports_cmake_script_path.generic_wstring());

        System::Stopwatch2 timer;
        timer.start();
        int return_code = System::cmd_execute(command);
        timer.stop();
        TrackMetric("buildtimeus-" + to_string(spec), timer.microseconds());

        if (return_code != 0)
        {
            System::println(System::color::error, "Error: building package %s failed", to_string(spec));
            System::println("Please ensure sure you're using the latest portfiles with `vcpkg update`, then\n"
                            "submit an issue at https://github.com/Microsoft/vcpkg/issues including:\n"
                            "  Package: %s\n"
                            "  Vcpkg version: %s\n"
                            "\n"
                            "Additionally, attach any relevant sections from the log files above."
                            , to_string(spec), Info::version());
            TrackProperty("error", "build failed");
            TrackProperty("build_error", to_string(spec));
            exit(EXIT_FAILURE);
        }

        perform_all_checks(spec, paths);

        create_binary_control_file(paths, source_paragraph, target_triplet);

        // const fs::path port_buildtrees_dir = paths.buildtrees / spec.name;
        // delete_directory(port_buildtrees_dir);
    }

    void install_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet)
    {
        static const std::string example = create_example_string("install zlib zlib:x64-windows curl boost");
        args.check_min_arg_count(1, example.c_str());
        StatusParagraphs status_db = database_load_check(paths);

        std::vector<package_spec> specs = Input::check_and_get_package_specs(args.command_arguments, default_target_triplet, example.c_str());
        Input::check_triplets(specs, paths);
        std::vector<package_spec_with_install_plan> install_plan = Dependencies::create_install_plan(paths, specs, status_db);
        Checks::check_exit(!install_plan.empty(), "Install plan cannot be empty");

        std::string specs_string = to_string(install_plan[0].spec);
        for (size_t i = 1; i < install_plan.size(); ++i)
        {
            specs_string.push_back(',');
            specs_string.append(to_string(install_plan[i].spec));
        }
        TrackProperty("installplan", specs_string);
        Environment::ensure_utilities_on_path(paths);

        for (const package_spec_with_install_plan& action : install_plan)
        {
            try
            {
                if (action.plan.type == install_plan_type::ALREADY_INSTALLED)
                {
                    if (std::find(specs.begin(), specs.end(), action.spec) != specs.end())
                    {
                        System::println(System::color::success, "Package %s is already installed", action.spec);
                    }
                }
                else if (action.plan.type == install_plan_type::BUILD_AND_INSTALL)
                {
                    build_internal(*action.plan.spgh, action.spec, paths, paths.port_dir(action.spec));
                    const BinaryParagraph bpgh = try_load_cached_package(paths, action.spec).get_or_throw();
                    install_package(paths, bpgh, status_db);
                    System::println(System::color::success, "Package %s is installed", action.spec);
                }
                else if (action.plan.type == install_plan_type::INSTALL)
                {
                    install_package(paths, *action.plan.bpgh, status_db);
                    System::println(System::color::success, "Package %s is installed", action.spec);
                }
                else
                    Checks::unreachable();
            }
            catch (const std::exception& e)
            {
                System::println(System::color::error, "Error: Could not install package %s: %s", action.spec, e.what());
                exit(EXIT_FAILURE);
            }
        }

        exit(EXIT_SUCCESS);
    }

    void build_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet)
    {
        static const std::string example = create_example_string("build zlib:x64-windows");

        // Installing multiple packages leads to unintuitive behavior if one of them depends on another.
        // Allowing only 1 package for now.

        args.check_exact_arg_count(1, example.c_str());

        StatusParagraphs status_db = database_load_check(paths);

        const package_spec spec = Input::check_and_get_package_spec(args.command_arguments.at(0), default_target_triplet, example.c_str());
        Input::check_triplet(spec.target_triplet(), paths);

        const std::unordered_set<std::string> options = args.check_and_get_optional_command_arguments({OPTION_CHECKS_ONLY});
        if (options.find(OPTION_CHECKS_ONLY) != options.end())
        {
            perform_all_checks(spec, paths);
            exit(EXIT_SUCCESS);
        }

        // Explicitly load and use the portfile's build dependencies when resolving the build command (instead of a cached package's dependencies).
        const expected<SourceParagraph> maybe_spgh = try_load_port(paths, spec.name());
        Checks::check_exit(!maybe_spgh.error_code(), "Could not find package named %s: %s", spec, maybe_spgh.error_code().message());
        const SourceParagraph& spgh = *maybe_spgh.get();

        const std::vector<std::string> first_level_deps = filter_dependencies(spgh.depends, spec.target_triplet());

        std::vector<package_spec> first_level_deps_specs;
        for (const std::string& dep : first_level_deps)
        {
            first_level_deps_specs.push_back(package_spec::from_name_and_triplet(dep, spec.target_triplet()).get_or_throw());
        }

        std::vector<package_spec_with_install_plan> unmet_dependencies = Dependencies::create_install_plan(paths, first_level_deps_specs, status_db);
        unmet_dependencies.erase(
            std::remove_if(unmet_dependencies.begin(), unmet_dependencies.end(), [](const package_spec_with_install_plan& p)
                           {
                               return p.plan.type == install_plan_type::ALREADY_INSTALLED;
                           }),
            unmet_dependencies.end());

        if (!unmet_dependencies.empty())
        {
            System::println(System::color::error, "The build command requires all dependencies to be already installed.");
            System::println("The following dependencies are missing:");
            System::println("");
            for (const package_spec_with_install_plan& p : unmet_dependencies)
            {
                System::println("    %s", to_string(p.spec));
            }
            System::println("");
            exit(EXIT_FAILURE);
        }

        Environment::ensure_utilities_on_path(paths);
        build_internal(spgh, spec, paths, paths.port_dir(spec));
        exit(EXIT_SUCCESS);
    }

    void build_external_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet)
    {
        static const std::string example = create_example_string(R"(build_external zlib2 C:\path\to\dir\with\controlfile\)");
        args.check_exact_arg_count(2, example.c_str());

        expected<package_spec> maybe_current_spec = package_spec::from_string(args.command_arguments[0], default_target_triplet);
        if (auto spec = maybe_current_spec.get())
        {
            Input::check_triplet(spec->target_triplet(), paths);
            Environment::ensure_utilities_on_path(paths);
            const fs::path port_dir = args.command_arguments.at(1);
            const expected<SourceParagraph> maybe_spgh = try_load_port(port_dir);
            if (auto spgh = maybe_spgh.get())
            {
                build_internal(*spgh, *spec, paths, port_dir);
                exit(EXIT_SUCCESS);
            }
        }

        System::println(System::color::error, "Error: %s: %s", maybe_current_spec.error_code().message(), args.command_arguments[0]);
        print_example(Strings::format("%s zlib:x64-windows", args.command).c_str());
        exit(EXIT_FAILURE);
    }
}
