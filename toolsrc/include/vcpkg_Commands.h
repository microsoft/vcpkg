#pragma once

#include "vcpkg_cmd_arguments.h"
#include "vcpkg_paths.h"

namespace vcpkg::Commands
{
    extern const char*const INTEGRATE_COMMAND_HELPSTRING;

    using command_type_a = void(*)(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet);
    using command_type_b = void(*)(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    using command_type_c = void(*)(const vcpkg_cmd_arguments& args);

    void update_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);

    void build_internal(const SourceParagraph& source_paragraph, const package_spec& spec, const vcpkg_paths& paths, const fs::path& port_dir);
    void build_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet);
    void build_external_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet);
    void install_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet);
    void remove_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet);

    void edit_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    void create_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);

    void search_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    void list_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    void import_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    void owns_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);

    void cache_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);

    void integrate_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);

    void portsdiff_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);

    void help_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths);
    void help_topic_valid_triplet(const vcpkg_paths& paths);

    void version_command(const vcpkg_cmd_arguments& args);
    void contact_command(const vcpkg_cmd_arguments& args);
    void hash_command(const vcpkg_cmd_arguments& args);

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

namespace vcpkg::Commands::Helpers
{
    void print_usage();

    void print_example(const std::string& command_and_arguments);

    std::string create_example_string(const std::string& command_and_arguments);
}
