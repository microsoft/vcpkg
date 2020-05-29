#pragma once

#include <vcpkg/base/optional.h>
#include <vcpkg/base/span.h>
#include <vcpkg/base/stringliteral.h>

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
        std::unordered_map<std::string, std::vector<std::string>> multisettings;
    };

    struct VcpkgPaths;

    struct CommandSwitch
    {
        constexpr CommandSwitch(const StringLiteral& name, const StringLiteral& short_help_text)
            : name(name), short_help_text(short_help_text)
        {
        }

        StringLiteral name;
        StringLiteral short_help_text;
    };

    struct CommandSetting
    {
        constexpr CommandSetting(const StringLiteral& name, const StringLiteral& short_help_text)
            : name(name), short_help_text(short_help_text)
        {
        }

        StringLiteral name;
        StringLiteral short_help_text;
    };

    struct CommandMultiSetting
    {
        constexpr CommandMultiSetting(const StringLiteral& name, const StringLiteral& short_help_text)
            : name(name), short_help_text(short_help_text)
        {
        }

        StringLiteral name;
        StringLiteral short_help_text;
    };

    struct CommandOptionsStructure
    {
        Span<const CommandSwitch> switches;
        Span<const CommandSetting> settings;
        Span<const CommandMultiSetting> multisettings;
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
        std::unique_ptr<std::string> install_root_dir;
        std::unique_ptr<std::string> scripts_root_dir;
        std::unique_ptr<std::string> triplet;
        std::unique_ptr<std::vector<std::string>> overlay_ports;
        std::unique_ptr<std::vector<std::string>> overlay_triplets;
        std::vector<std::string> binarysources;
        Optional<bool> debug = nullopt;
        Optional<bool> sendmetrics = nullopt;
        // fully disable metrics -- both printing and sending
        Optional<bool> disable_metrics = nullopt;
        Optional<bool> printmetrics = nullopt;

        // feature flags
        Optional<bool> featurepackages = nullopt;
        Optional<bool> binarycaching = nullopt;

        std::string command;
        std::vector<std::string> command_arguments;

        ParsedArguments parse_arguments(const CommandStructure& command_structure) const;

    private:
        std::unordered_map<std::string, Optional<std::vector<std::string>>> optional_command_arguments;
    };
}
