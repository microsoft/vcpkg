#pragma once

#include <vcpkg/base/expected.h>
#include <vcpkg/base/files.h>

#include <vcpkg/packagespec.h>
#include <vcpkg/vcpkgpaths.h>

#include <set>

namespace vcpkg::Dependencies
{
    struct InstallPlanAction;
    struct ActionPlan;
}
namespace vcpkg::Build
{
    struct AbiTagAndFile;
    struct BuildPackageOptions;
}

namespace vcpkg
{
    struct MergeBinaryProviders;

    enum class RestoreResult
    {
        missing,
        success,
        build_failed,
    };

    struct IBinaryProvider
    {
        virtual ~IBinaryProvider() = default;
        /// Gives the BinaryProvider an opportunity to batch any downloading or server communication for executing
        /// `plan`.
        void prefetch(const VcpkgPaths& paths, const Dependencies::ActionPlan& plan);
        /// Attempts to restore the package referenced by `action` into the packages directory.
        virtual RestoreResult try_restore(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action);
        /// Called upon a successful build of `action`
        virtual void push_success(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action);
        /// Requests the result of `try_restore()` without actually downloading the package. Used by CI to determine
        /// missing packages.
        std::unordered_map<const Dependencies::InstallPlanAction*, RestoreResult> precheck(
            const VcpkgPaths& paths, View<Dependencies::InstallPlanAction> actions);

        friend struct MergeBinaryProviders;

    protected:
        virtual void prefetch(const VcpkgPaths& paths,
                              const Dependencies::ActionPlan& plan,
                              std::set<PackageSpec>* restored);

        /// Requests the result of `try_restore()` without actually downloading the package. Used by CI to determine
        /// missing packages.
        virtual void precheck(const VcpkgPaths& paths,
                              std::unordered_map<const Dependencies::InstallPlanAction*, RestoreResult>* results_map);
    };

    IBinaryProvider& null_binary_provider();

    ExpectedS<std::unique_ptr<IBinaryProvider>> create_binary_provider_from_configs(View<std::string> args);
    ExpectedS<std::unique_ptr<IBinaryProvider>> create_binary_provider_from_configs_pure(const std::string& env_string,
                                                                                         View<std::string> args);

    std::string generate_nuget_packages_config(const Dependencies::ActionPlan& action);

    void help_topic_binary_caching(const VcpkgPaths& paths);
}
