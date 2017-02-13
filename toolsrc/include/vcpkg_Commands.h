#pragma once

#include "vcpkg_cmd_arguments.h"
#include "vcpkg_paths.h"
#include "StatusParagraphs.h"

namespace vcpkg::Commands
{
    using command_type_a = void(*)(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet);
    using command_type_b = void(*)(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    using command_type_c = void(*)(const vcpkg_cmd_arguments& args);

    namespace Build
    {
        enum class BuildResult
        {
            BUILD_NOT_STARTED = 0,
            SUCCEEDED,
            BUILD_FAILED,
            POST_BUILD_CHECKS_FAILED,
            CASCADED_DUE_TO_MISSING_DEPENDENCIES
        };

        const std::string& to_string(const BuildResult build_result);
        std::string create_error_message(const std::string& package_id, const BuildResult build_result);

        BuildResult build_package(const SourceParagraph& source_paragraph, const package_spec& spec, const vcpkg_paths& paths, const fs::path& port_dir, const StatusParagraphs& status_db);
        void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet);
    }

    namespace BuildExternal
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet);
    }

    namespace Install
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet);
    }

    namespace Remove
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet);
    }

    namespace Update
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    }

    namespace Create
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    }

    namespace Edit
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    }

    namespace Search
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    }

    namespace List
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    }

    namespace Import
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    }

    namespace Owns
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    }

    namespace Cache
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    }

    namespace Integrate
    {
        extern const char*const INTEGRATE_COMMAND_HELPSTRING;

        void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    }

    namespace PortsDiff
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    }

    namespace Help
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);

        void help_topic_valid_triplet(const vcpkg_paths& paths);

        void print_usage();

        void print_example(const std::string& command_and_arguments);

        std::string create_example_string(const std::string& command_and_arguments);
    }

    namespace Version
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args);
    }

    namespace Contact
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args);
    }

    namespace Hash
    {
        void perform_and_exit(const vcpkg_cmd_arguments& args);
    }

    template <class T>
    struct package_name_and_function
    {
        std::string name;
        T function;
    };

    const std::vector<package_name_and_function<command_type_a>>& get_available_commands_type_a();
    const std::vector<package_name_and_function<command_type_b>>& get_available_commands_type_b();
    const std::vector<package_name_and_function<command_type_c>>& get_available_commands_type_c();

    template <typename T>
    T find(const std::string& command_name, const std::vector<package_name_and_function<T>> available_commands)
    {
        for (const package_name_and_function<T>& cmd : available_commands)
        {
            if (cmd.name == command_name)
            {
                return cmd.function;
            }
        }

        // not found
        return nullptr;
    }
}
