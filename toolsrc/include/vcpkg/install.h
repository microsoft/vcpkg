#pragma once

#include <vcpkg/base/chrono.h>
#include <vcpkg/build.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

#include <vector>

namespace vcpkg::Install
{
    enum class KeepGoing
    {
        NO = 0,
        YES
    };

    inline KeepGoing to_keep_going(const bool value) { return value ? KeepGoing::YES : KeepGoing::NO; }

    struct SpecSummary
    {
        SpecSummary(const PackageSpec& spec, const Dependencies::InstallPlanAction* action);

        const BinaryParagraph* get_binary_paragraph() const;

        PackageSpec spec;
        Build::ExtendedBuildResult build_result;
        vcpkg::Chrono::ElapsedTime timing;

        const Dependencies::InstallPlanAction* action;
    };

    struct InstallSummary
    {
        std::vector<SpecSummary> results;
        std::string total_elapsed_time;

        void print() const;
        std::string xunit_results() const;
    };

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

    Build::ExtendedBuildResult perform_install_plan_action(const VcpkgPaths& paths,
                                                           Dependencies::InstallPlanAction& action,
                                                           StatusParagraphs& status_db,
                                                           const CMakeVars::CMakeVarProvider& var_provider);

    enum class InstallResult
    {
        FILE_CONFLICTS,
        SUCCESS,
    };

    std::vector<std::string> get_all_port_names(const VcpkgPaths& paths);

    void install_files_and_write_listfile(Files::Filesystem& fs, const fs::path& source_dir, const InstallDir& dirs);
    InstallResult install_package(const VcpkgPaths& paths,
                                  const BinaryControlFile& binary_paragraph,
                                  StatusParagraphs* status_db);

    InstallSummary perform(Dependencies::ActionPlan& action_plan,
                           const KeepGoing keep_going,
                           const VcpkgPaths& paths,
                           StatusParagraphs& status_db,
                           const CMakeVars::CMakeVarProvider& var_provider);

    extern const CommandStructure COMMAND_STRUCTURE;

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);
}
