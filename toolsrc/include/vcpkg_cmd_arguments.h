#pragma once

#include <memory>
#include <vector>
#include <unordered_set>
#include "OptBool.h"

namespace vcpkg
{
    struct vcpkg_cmd_arguments
    {
        static vcpkg_cmd_arguments create_from_command_line(const int argc, const wchar_t* const* const argv);
        static vcpkg_cmd_arguments create_from_arg_sequence(const std::string* arg_begin, const std::string* arg_end);

        std::unique_ptr<std::string> vcpkg_root_dir;
        std::unique_ptr<std::string> target_triplet;
        OptBoolT debug = OptBoolT::UNSPECIFIED;
        OptBoolT  sendmetrics = OptBoolT::UNSPECIFIED;
        OptBoolT  printmetrics = OptBoolT::UNSPECIFIED;

        std::string command;
        std::vector<std::string> command_arguments;
        std::unordered_set<std::string> check_and_get_optional_command_arguments(const std::vector<std::string>& valid_options) const;

        void check_max_arg_count(const size_t expected_arg_count) const;
        void check_max_arg_count(const size_t expected_arg_count, const std::string& example_text) const;
        void check_min_arg_count(const size_t expected_arg_count) const;
        void check_min_arg_count(const size_t expected_arg_count, const std::string& example_text) const;
        void check_exact_arg_count(const size_t expected_arg_count) const;
        void check_exact_arg_count(const size_t expected_arg_count, const std::string& example_text) const;

    private:
        std::unordered_set<std::string> optional_command_arguments;
    };
}
