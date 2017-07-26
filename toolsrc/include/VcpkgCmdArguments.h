#pragma once

#include "vcpkg_optional.h"
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

    struct VcpkgCmdArguments
    {
        static VcpkgCmdArguments create_from_command_line(const int argc, const wchar_t* const* const argv);
        static VcpkgCmdArguments create_from_arg_sequence(const std::string* arg_begin, const std::string* arg_end);

        std::unique_ptr<std::string> vcpkg_root_dir;
        std::unique_ptr<std::string> triplet;
        Optional<bool> debug = nullopt;
        Optional<bool> sendmetrics = nullopt;
        Optional<bool> printmetrics = nullopt;

        std::string command;
        std::vector<std::string> command_arguments;
        std::unordered_set<std::string> check_and_get_optional_command_arguments(
            const std::vector<std::string>& valid_options) const
        {
            return std::move(check_and_get_optional_command_arguments(valid_options, {}).switches);
        }

        ParsedArguments check_and_get_optional_command_arguments(const std::vector<std::string>& valid_switches,
                                                                 const std::vector<std::string>& valid_settings) const;

        void check_max_arg_count(const size_t expected_arg_count) const;
        void check_max_arg_count(const size_t expected_arg_count, const std::string& example_text) const;
        void check_min_arg_count(const size_t expected_arg_count) const;
        void check_min_arg_count(const size_t expected_arg_count, const std::string& example_text) const;
        void check_exact_arg_count(const size_t expected_arg_count) const;
        void check_exact_arg_count(const size_t expected_arg_count, const std::string& example_text) const;

    private:
        std::unordered_map<std::string, Optional<std::string>> optional_command_arguments;
    };
}
