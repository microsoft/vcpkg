#include "pch.h"

#include "Paragraphs.h"
#include "vcpkg_Commands.h"
#include "vcpkg_Strings.h"
#include "vcpkg_System.h"

namespace vcpkg::Commands::DependInfo
{
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        static const std::string example = Commands::Help::create_example_string(R"###(depend-info)###");
        args.check_exact_arg_count(0, example);
        args.check_and_get_optional_command_arguments({});

        const std::vector<SourceControlFile> source_control_files =
            Paragraphs::load_all_ports(paths.get_filesystem(), paths.ports);

        for (const SourceControlFile& source_control_file : source_control_files)
        {
            const SourceParagraph& source_paragraph = source_control_file.core_paragraph;
            auto s = Strings::join(", ", source_paragraph.depends, [](const Dependency& d) { return d.name; });
            System::println("%s: %s", source_paragraph.name, s);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
