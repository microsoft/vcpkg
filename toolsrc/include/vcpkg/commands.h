#pragma once

#include <vcpkg/build.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/statusparagraphs.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

#include <array>
#include <map>
#include <vector>

namespace vcpkg::Commands
{
    using CommandTypeA = void (*)(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);
    using CommandTypeB = void (*)(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    using CommandTypeC = void (*)(const VcpkgCmdArguments& args, Files::Filesystem& fs);

    enum class DryRun : bool
    {
        No,
        Yes,
    };

    namespace BuildExternal
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);
    }

    namespace CI
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);
    }

    namespace CIClean
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Env
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);
    }

    namespace Create
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        int perform(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Upgrade
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);
    }

    namespace Edit
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace DependInfo
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);
    }

    namespace Search
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace List
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Owns
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Cache
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Integrate
    {
        extern const CommandStructure COMMAND_STRUCTURE;

        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
        void append_helpstring(HelpTableFormatter& table);
        std::string get_helpstring();
    }

    namespace PortsDiff
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace PortHistory
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Autocomplete
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Version
    {
        const char* base_version();
        const std::string& version();
        void warn_if_vcpkg_version_mismatch(const VcpkgPaths& paths);
        void perform_and_exit(const VcpkgCmdArguments& args, Files::Filesystem& fs);
    }

    namespace Contact
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        const std::string& email();
        void perform_and_exit(const VcpkgCmdArguments& args, Files::Filesystem& fs);
    }

    namespace X_VSInstances
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Hash
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace Fetch
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace FormatManifest
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }

    namespace SetInstalled
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        void perform_and_exit_ex(const VcpkgCmdArguments& args,
                                 const VcpkgPaths& paths,
                                 const PortFileProvider::PathsPortFileProvider& provider,
                                 IBinaryProvider& binary_provider,
                                 const CMakeVars::CMakeVarProvider& cmake_vars,
                                 const std::vector<FullPackageSpec>& specs,
                                 const Build::BuildPackageOptions& install_plan_options,
                                 DryRun dry_run,
                                 const Optional<fs::path>& pkgsconfig_path);
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);
    }

    template<class T>
    struct PackageNameAndFunction
    {
        std::string name;
        T function;
    };

    Span<const PackageNameAndFunction<CommandTypeA>> get_available_commands_type_a();
    Span<const PackageNameAndFunction<CommandTypeB>> get_available_commands_type_b();
    Span<const PackageNameAndFunction<CommandTypeC>> get_available_commands_type_c();

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
