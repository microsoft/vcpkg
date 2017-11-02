#pragma once

#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

#include <string>

namespace vcpkg::Help
{
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);

    void help_topic_valid_triplet(const VcpkgPaths& paths);

    void print_usage();

    void print_example(const std::string& command_and_arguments);

    std::string create_example_string(const std::string& command_and_arguments);
}
