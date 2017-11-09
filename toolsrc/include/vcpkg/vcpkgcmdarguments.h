#pragma once

#include <vcpkg/base/cstringview.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/span.h>

#include <memory>
#include <unordered_map>
#include <unordered_set>
#include <vector>

namespace vcpkg
{
    struct ParsedArguments
    {
        std::unordered_set<std::string> switches;
        std::unordered_map<std::string, std::string> settings;
    };

    struct VcpkgPaths;

    struct CommandSwitch
    {
        std::string name;
        CStringView short_help_text;
    };

    struct CommandSetting
    {
        std::string name;
        CStringView short_help_text;
    };

    struct CommandOptionsStructure
    {
        Span<const CommandSwitch> switches;
        Span<const CommandSetting> settings;
    };

    struct CommandStructure
    {
        std::string example_text;

        size_t minimum_arity;
        size_t maximum_arity;

        CommandOptionsStructure options;

        std::vector<std::string> (*valid_arguments)(const VcpkgPaths& paths);
    };

    void display_usage(const CommandStructure& command_structure);

#if defined(_WIN32)
    using CommandLineCharType = wchar_t;
#else
    using CommandLineCharType = char;
#endif

    struct VcpkgCmdArguments
    {
        static VcpkgCmdArguments create_from_command_line(const int argc, const CommandLineCharType* const* const argv);
        static VcpkgCmdArguments create_from_arg_sequence(const std::string* arg_begin, const std::string* arg_end);

        std::unique_ptr<std::string> vcpkg_root_dir;
        std::unique_ptr<std::string> triplet;
        Optional<bool> debug = nullopt;
        Optional<bool> sendmetrics = nullopt;
        Optional<bool> printmetrics = nullopt;

        std::string command;
        std::vector<std::string> command_arguments;

        ParsedArguments parse_arguments(const CommandStructure& command_structure) const;

    private:
        std::unordered_map<std::string, Optional<std::string>> optional_command_arguments;
    };
}
