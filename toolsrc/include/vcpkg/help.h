#pragma once

#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

#include <string>

namespace vcpkg::Help
{
    extern const CommandStructure COMMAND_STRUCTURE;

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);

    void help_topic_valid_triplet(const VcpkgPaths& paths);

    void print_usage();

    std::string create_example_string(const std::string& command_and_arguments);

    struct HelpTableFormatter
    {
        void format(StringView col1, StringView col2);

        std::string m_str;

    private:
        void newline_indent();
        void indent();
    };

}
