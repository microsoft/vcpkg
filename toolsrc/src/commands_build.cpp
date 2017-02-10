#include "pch.h"
#include "vcpkg_Commands.h"
#include "StatusParagraphs.h"
#include "vcpkglib.h"
#include "vcpkg_Input.h"
#include "PostBuildLint.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_System.h"
#include "vcpkg_Environment.h"
#include "metrics.h"
#include "vcpkg_info.h"
#include "vcpkg_Enums.h"

namespace vcpkg::Commands::Build
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

    BuildResult build_package(const SourceParagraph& source_paragraph, const package_spec& spec, const vcpkg_paths& paths, const fs::path& port_dir)
    {
        Checks::check_exit(spec.name() == source_paragraph.name, "inconsistent arguments to build_package()");
        const triplet& target_triplet = spec.target_triplet();

        const fs::path ports_cmake_script_path = paths.ports_cmake;
        const Environment::vcvarsall_and_platform_toolset vcvarsall_bat = Environment::get_vcvarsall_bat(paths);
        const std::wstring command = Strings::wformat(LR"("%s" %s >nul 2>&1 && cmake -DCMD=BUILD -DPORT=%s -DTARGET_TRIPLET=%s -DVCPKG_PLATFORM_TOOLSET=%s "-DCURRENT_PORT_DIR=%s/." -P "%s")",
                                                      vcvarsall_bat.path.native(),
                                                      Strings::utf8_to_utf16(target_triplet.architecture()),
                                                      Strings::utf8_to_utf16(source_paragraph.name),
                                                      Strings::utf8_to_utf16(target_triplet.canonical_name()),
                                                      vcvarsall_bat.platform_toolset,
                                                      port_dir.generic_wstring(),
                                                      ports_cmake_script_path.generic_wstring());

        System::Stopwatch2 timer;
        timer.start();
        int return_code = System::cmd_execute(command);
        timer.stop();
        TrackMetric("buildtimeus-" + spec.toString(), timer.microseconds());

        if (return_code != 0)
        {
            System::println(System::color::error, "Error: building package %s failed", spec.toString());
            System::println("Please ensure sure you're using the latest portfiles with `vcpkg update`, then\n"
                            "submit an issue at https://github.com/Microsoft/vcpkg/issues including:\n"
                            "  Package: %s\n"
                            "  Vcpkg version: %s\n"
                            "\n"
                            "Additionally, attach any relevant sections from the log files above."
                            , spec.toString(), Info::version());
            TrackProperty("error", "build failed");
            TrackProperty("build_error", spec.toString());
            return BuildResult::BUILD_FAILED;
        }

        const size_t error_count = PostBuildLint::perform_all_checks(spec, paths);

        if (error_count != 0)
        {
            return BuildResult::POST_BUILD_CHECKS_FAILED;
        }

        create_binary_control_file(paths, source_paragraph, target_triplet);

        // const fs::path port_buildtrees_dir = paths.buildtrees / spec.name;
        // delete_directory(port_buildtrees_dir);

        return BuildResult::SUCCESS;
    }

    void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet)
    {
        static const std::string example = Commands::Help::create_example_string("build zlib:x64-windows");

        // Installing multiple packages leads to unintuitive behavior if one of them depends on another.
        // Allowing only 1 package for now.

        args.check_exact_arg_count(1, example);

        StatusParagraphs status_db = database_load_check(paths);

        const package_spec spec = Input::check_and_get_package_spec(args.command_arguments.at(0), default_target_triplet, example);
        Input::check_triplet(spec.target_triplet(), paths);

        const std::unordered_set<std::string> options = args.check_and_get_optional_command_arguments({OPTION_CHECKS_ONLY});
        if (options.find(OPTION_CHECKS_ONLY) != options.end())
        {
            const size_t error_count = PostBuildLint::perform_all_checks(spec, paths);
            if (error_count > 0)
            {
                exit(EXIT_FAILURE);
            }
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
                               return p.plan.plan_type == install_plan_type::ALREADY_INSTALLED;
                           }),
            unmet_dependencies.end());

        if (!unmet_dependencies.empty())
        {
            System::println(System::color::error, "The build command requires all dependencies to be already installed.");
            System::println("The following dependencies are missing:");
            System::println("");
            for (const package_spec_with_install_plan& p : unmet_dependencies)
            {
                System::println("    %s", p.spec.toString());
            }
            System::println("");
            exit(EXIT_FAILURE);
        }

        Environment::ensure_utilities_on_path(paths);
        const BuildResult result = build_package(spgh, spec, paths, paths.port_dir(spec));
        if (result != BuildResult::SUCCESS)
        {
            exit(EXIT_FAILURE);
        }

        exit(EXIT_SUCCESS);
    }
}
