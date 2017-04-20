#pragma once

#include "VcpkgCmdArguments.h"
#include "VcpkgPaths.h"
#include "StatusParagraphs.h"
#include <array>
#include "VersionT.h"

namespace vcpkg::Commands
{
    using CommandTypeA = void(*)(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
    using CommandTypeB = void(*)(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    using CommandTypeC = void(*)(const VcpkgCmdArguments& args);

    namespace Build
    {
        enum class BuildResult
        {
            NULLVALUE = 0,
            SUCCEEDED,
            BUILD_FAILED,
            POST_BUILD_CHECKS_FAILED,
            CASCADED_DUE_TO_MISSING_DEPENDENCIES
        };

        static constexpr std::array<BuildResult, 4> BuildResult_values = { BuildResult::SUCCEEDED, BuildResult::BUILD_FAILED, BuildResult::POST_BUILD_CHECKS_FAILED, BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES };

        const std::string& to_string(const BuildResult build_result);
        std::string create_error_message(const BuildResult build_result, const PackageSpec& spec);
        std::string create_user_troubleshooting_message(const PackageSpec& spec);

        std::wstring make_build_env_cmd(const Triplet& triplet, const Toolset& toolset);

        BuildResult build_package(const SourceParagraph& source_paragraph, const PackageSpec& spec, const VcpkgPaths& paths, const fs::path& port_dir, const StatusParagraphs& status_db);
        void perform_and_exit(const PackageSpec& spec, const fs::path& port_dir, const std::unordered_set<std::string>& options, const VcpkgPaths& paths);
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
    }

    namespace BuildExternal
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
    }

    namespace Install
    {
        struct InstallDir
        {
            static InstallDir from_destination_root(const fs::path& source_dir,
                                                    const fs::path& destination_root,
                                                    const std::string& destination_subdirectory,
                                                    const fs::path& listfile);

        private:
            fs::path m_source_dir; // "source" from source-destination, not source code.
            fs::path m_destination;
            std::string m_destination_subdirectory;
            fs::path m_listfile;

        public:
            const fs::path& source_dir() const;
            const fs::path& destination() const;
            const std::string& destination_subdirectory() const;
            const fs::path& listfile() const;
        };

        void install_files_and_write_listfile(Files::Filesystem& fs, const InstallDir& dirs);
        void install_package(const VcpkgPaths& paths, const BinaryParagraph& binary_paragraph, StatusParagraphs* status_db);
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
    }

    namespace CI
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
    }

    namespace Remove
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
    }

    namespace Update
    {
        struct OutdatedPackage
        {
            static bool compare_by_name(const OutdatedPackage& left, const OutdatedPackage& right);

            PackageSpec spec;
            VersionDiff version_diff;
        };

        std::vector<OutdatedPackage> find_outdated_packages(const VcpkgPaths& paths, const StatusParagraphs& status_db);
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Env
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
    }

    namespace Create
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Edit
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace DependInfo
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Search
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace List
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Owns
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Cache
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Import
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Integrate
    {
        extern const char*const INTEGRATE_COMMAND_HELPSTRING;

        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace PortsDiff
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Help
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);

        void help_topic_valid_triplet(const VcpkgPaths& paths);

        void print_usage();

        void print_example(const std::string& command_and_arguments);

        std::string create_example_string(const std::string& command_and_arguments);
    }

    namespace Version
    {
        const std::string& version();
        void perform_and_exit(const VcpkgCmdArguments& args);
    }

    namespace Contact
    {
        const std::string& email();
        void perform_and_exit(const VcpkgCmdArguments& args);
    }

    namespace Hash
    {
        void perform_and_exit(const VcpkgCmdArguments& args);
    }

    template<class T>
    struct PackageNameAndFunction
    {
        std::string name;
        T function;
    };

    const std::vector<PackageNameAndFunction<CommandTypeA>>& get_available_commands_type_a();
    const std::vector<PackageNameAndFunction<CommandTypeB>>& get_available_commands_type_b();
    const std::vector<PackageNameAndFunction<CommandTypeC>>& get_available_commands_type_c();

    template<typename T>
    T find(const std::string& command_name, const std::vector<PackageNameAndFunction<T>> available_commands)
    {
        for (const PackageNameAndFunction<T>& cmd : available_commands)
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
