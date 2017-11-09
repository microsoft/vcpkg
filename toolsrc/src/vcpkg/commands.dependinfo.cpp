#include "pch.h"

#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/paragraphs.h>

namespace vcpkg::Commands::DependInfo
{
    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string(R"###(depend-info [pat])###"),
        0,
        1,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        args.parse_arguments(COMMAND_STRUCTURE);

        std::vector<std::unique_ptr<SourceControlFile>> source_control_files =
            Paragraphs::load_all_ports(paths.get_filesystem(), paths.ports);

        if (args.command_arguments.size() == 1)
        {
            const std::string filter = args.command_arguments.at(0);

            Util::erase_remove_if(source_control_files,
                                  [&](const std::unique_ptr<SourceControlFile>& source_control_file) {

                                      const SourceParagraph& source_paragraph = *source_control_file->core_paragraph;

                                      if (Strings::case_insensitive_ascii_contains(source_paragraph.name, filter))
                                      {
                                          return false;
                                      }

                                      for (const Dependency& dependency : source_paragraph.depends)
                                      {
                                          if (Strings::case_insensitive_ascii_contains(dependency.name(), filter))
                                          {
                                              return false;
                                          }
                                      }

                                      return true;
                                  });
        }

        for (auto&& source_control_file : source_control_files)
        {
            const SourceParagraph& source_paragraph = *source_control_file->core_paragraph;
            const auto s = Strings::join(", ", source_paragraph.depends, [](const Dependency& d) { return d.name(); });
            System::println("%s: %s", source_paragraph.name, s);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
