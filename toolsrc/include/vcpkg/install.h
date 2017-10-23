#pragma once

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
        explicit SpecSummary(const PackageSpec& spec);

        PackageSpec spec;
        Build::BuildResult result;
        std::string timing;
    };

    struct InstallSummary
    {
        std::vector<SpecSummary> results;
        std::string total_elapsed_time;

        void print() const;
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

    Build::BuildResult perform_install_plan_action(const VcpkgPaths& paths,
                                                   const Dependencies::InstallPlanAction& action,
                                                   const Build::BuildPackageOptions& install_plan_options,
                                                   StatusParagraphs& status_db);

    enum class InstallResult
    {
        FILE_CONFLICTS,
        SUCCESS,
    };

    void install_files_and_write_listfile(Files::Filesystem& fs, const fs::path& source_dir, const InstallDir& dirs);
    InstallResult install_package(const VcpkgPaths& paths,
                                  const BinaryControlFile& binary_paragraph,
                                  StatusParagraphs* status_db);

    InstallSummary perform(const std::vector<Dependencies::AnyAction>& action_plan,
                           const Build::BuildPackageOptions& install_plan_options,
                           const KeepGoing keep_going,
                           const VcpkgPaths& paths,
                           StatusParagraphs& status_db);

    extern const CommandStructure COMMAND_STRUCTURE;

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
}
