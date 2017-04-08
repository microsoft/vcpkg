#include "pch.h"
#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "Paragraphs.h"
#include "vcpkg_Strings.h"

namespace vcpkg::Commands::DependInfo
{
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        static const std::string example = Commands::Help::create_example_string(R"###(depend-info)###");
        args.check_exact_arg_count(0, example);
        args.check_and_get_optional_command_arguments({});

        const std::vector<SourceParagraph> source_paragraphs = Paragraphs::load_all_ports(paths.get_filesystem(), paths.ports);

        for (const SourceParagraph& source_paragraph : source_paragraphs)
        {
            auto s = Strings::join(", ", source_paragraph.depends, [](const Dependency& d) { return d.name; });
            System::println("%s: %s", source_paragraph.name, s);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
