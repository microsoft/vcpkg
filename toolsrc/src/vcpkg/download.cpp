#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>
#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/download.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/metrics.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/remove.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Download
{
    using namespace Dependencies;

    using Build::BuildResult;
    using Build::ExtendedBuildResult;

    static constexpr StringLiteral OPTION_USE_HEAD_VERSION = "--head";
    static constexpr StringLiteral OPTION_KEEP_GOING = "--keep-going";
    static constexpr StringLiteral OPTION_USE_ARIA2 = "--x-use-aria2";

    static constexpr std::array<CommandSwitch, 3> INSTALL_SWITCHES = {{
        {OPTION_USE_HEAD_VERSION, "Install the libraries on the command line using the latest upstream sources"},
        {OPTION_KEEP_GOING, "Continue installing packages on failure"},
        {OPTION_USE_ARIA2, "Use aria2 to perform download tasks"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("download zlib zlib:x64-windows curl boost"),
        1,
        SIZE_MAX,
        {INSTALL_SWITCHES},
        &Install::get_all_port_names,
    };

    ///
    /// <summary>
    /// Run "install" command.
    /// </summary>
    ///
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        // input sanitization
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        const bool use_head_version = Util::Sets::contains(options.switches, (OPTION_USE_HEAD_VERSION));
        const bool use_aria2 = Util::Sets::contains(options.switches, (OPTION_USE_ARIA2));

        Build::DownloadTool download_tool = Build::DownloadTool::BUILT_IN;
        if (use_aria2) download_tool = Build::DownloadTool::ARIA2;

        const Build::BuildPackageOptions install_plan_options = {
            Util::Enum::to_enum<Build::UseHeadVersion>(use_head_version),
            Build::AllowDownloads::YES,
            Build::CleanBuildtrees::NO,
            Build::CleanPackages::NO,
            Build::CleanDownloads::NO,
            download_tool,
            Build::BinaryCaching::NO,
            Build::FailOnTombstone::NO,
            Build::DownloadOnly::YES,
        };

        // delegate the rest of this to however "Install" works.
        Install::perform_and_exit(args, paths, default_triplet, install_plan_options, options);
    }
}
