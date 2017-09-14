#pragma once

#include "StatusParagraphs.h"
#include "VcpkgCmdArguments.h"
#include "VcpkgPaths.h"
#include "VersionT.h"
#include "vcpkg_Build.h"
#include "vcpkg_Dependencies.h"
#include <array>

namespace vcpkg::Commands
{
    using CommandTypeA = void (*)(const VcpkgCmdArguments& args,
                                  const VcpkgPaths& paths,
                                  const Triplet& default_triplet);
    using CommandTypeB = void (*)(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    using CommandTypeC = void (*)(const VcpkgCmdArguments& args);

    namespace BuildCommand
    {
        void perform_and_exit(const FullPackageSpec& full_spec,
                              const fs::path& port_dir,
                              const std::unordered_set<std::string>& options,
                              const VcpkgPaths& paths);

        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
    }

    namespace BuildExternal
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
    }

    namespace Install
    {
        enum class KeepGoing
        {
            NO = 0,
            YES
        };

        inline KeepGoing to_keep_going(const bool value) { return value ? KeepGoing::YES : KeepGoing::NO; }

        enum class PrintSummary
        {
            NO = 0,
            YES
        };

        inline PrintSummary to_print_summary(const bool value) { return value ? PrintSummary::YES : PrintSummary::NO; }

        struct InstallDir
        {
            static InstallDir from_destination_root(const fs::path& destination_root,
                                                    const std::string& destination_subdirectory,
                                                    const fs::path& listfile);

        private:
            fs::path m_destination;
            std::string m_destination_subdirectory;
            fs::path m_listfile;

        public:
            const fs::path& destination() const;
            const std::string& destination_subdirectory() const;
            const fs::path& listfile() const;
        };

        Build::BuildResult perform_install_plan_action(const VcpkgPaths& paths,
                                                       const Dependencies::InstallPlanAction& action,
                                                       const Build::BuildPackageOptions& install_plan_options,
                                                       StatusParagraphs& status_db);

        enum class InstallResult
        {
            FILE_CONFLICTS,
            SUCCESS,
        };

        void install_files_and_write_listfile(Files::Filesystem& fs,
                                              const fs::path& source_dir,
                                              const InstallDir& dirs);
        InstallResult install_package(const VcpkgPaths& paths,
                                      const BinaryControlFile& binary_paragraph,
                                      StatusParagraphs* status_db);

        void perform_and_exit(const std::vector<Dependencies::AnyAction>& action_plan,
                              const Build::BuildPackageOptions& install_plan_options,
                              const KeepGoing keep_going,
                              const PrintSummary print_summary,
                              const VcpkgPaths& paths,
                              StatusParagraphs& status_db);

        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
    }

    namespace Export
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
    }

    namespace CI
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
    }

    namespace Remove
    {
        enum class Purge
        {
            NO = 0,
            YES
        };

        inline Purge to_purge(const bool value) { return value ? Purge::YES : Purge::NO; }

        void perform_remove_plan_action(const VcpkgPaths& paths,
                                        const Dependencies::RemovePlanAction& action,
                                        const Purge purge,
                                        StatusParagraphs& status_db);

        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
        void remove_package(const VcpkgPaths& paths, const PackageSpec& spec, StatusParagraphs* status_db);
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
        extern const char* const INTEGRATE_COMMAND_HELPSTRING;

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
