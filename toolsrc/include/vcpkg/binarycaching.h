#pragma once

#include <vcpkg/fwd/dependencies.h>
#include <vcpkg/fwd/vcpkgpaths.h>

#include <vcpkg/base/expected.h>
#include <vcpkg/base/files.h>

#include <vcpkg/packagespec.h>

#include <unordered_map>

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

        /// Attempts to restore the package referenced by `action` into the packages directory.
        virtual RestoreResult try_restore(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action) = 0;

        /// Called upon a successful build of `action`
        virtual void push_success(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action) = 0;

        /// <summary>Gives the BinaryProvider an opportunity to batch any downloading or server communication for
        /// executing `plan`.</summary>
        /// <remarks>Must only be called once for a given binary provider instance</remarks>
        /// <param name="actions">InOut vector of actions to be prefetched</param>
        virtual void prefetch(const VcpkgPaths& paths,
                              std::vector<const Dependencies::InstallPlanAction*>& actions) = 0;

        /// <summary>Requests the result of <c>try_restore()</c> without actually downloading the package. Used by CI to
        /// determine missing packages.</summary>
        /// <param name="results_map">InOut map to track the restored packages. Should be initialized to
        /// <c>{&amp;action, RestoreResult::missing}</c> for all install actions</param>
        virtual void precheck(
            const VcpkgPaths& paths,
            std::unordered_map<const Dependencies::InstallPlanAction*, RestoreResult>& results_map) = 0;
    };

    std::unordered_map<const Dependencies::InstallPlanAction*, RestoreResult> binary_provider_precheck(
        const VcpkgPaths& paths, const Dependencies::ActionPlan& plan, IBinaryProvider& provider);

    IBinaryProvider& null_binary_provider();

    ExpectedS<std::unique_ptr<IBinaryProvider>> create_binary_provider_from_configs(View<std::string> args);
    ExpectedS<std::unique_ptr<IBinaryProvider>> create_binary_provider_from_configs_pure(const std::string& env_string,
                                                                                         View<std::string> args);

    std::string generate_nuget_packages_config(const Dependencies::ActionPlan& action);

    void help_topic_binary_caching(const VcpkgPaths& paths);
}
