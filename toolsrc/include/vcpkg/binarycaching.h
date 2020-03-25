#pragma once

#include <vcpkg/base/expected.h>
#include <vcpkg/base/files.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::Dependencies
{
    struct InstallPlanAction;
}
namespace vcpkg::Build
{
    struct AbiTagAndFile;
    struct BuildPackageOptions;
}

namespace vcpkg
{
    enum class RestoreResult
    {
        missing,
        success,
        build_failed,
    };

    struct IBinaryProvider
    {
        virtual ~IBinaryProvider() = default;
        virtual void prefetch() = 0;
        virtual RestoreResult try_restore(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action) = 0;
        virtual void push_success(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action) = 0;
        virtual void push_failure(const VcpkgPaths& paths, const std::string& abi_tag, const PackageSpec& spec) = 0;
        virtual RestoreResult precheck(const VcpkgPaths& paths,
                                       const Dependencies::InstallPlanAction& action,
                                       bool purge_tombstones) = 0;
    };

    ExpectedS<std::unique_ptr<IBinaryProvider>> create_binary_provider_from_configs(const VcpkgPaths& paths,
                                                                                    View<std::string> args);
    ExpectedS<std::unique_ptr<IBinaryProvider>> create_binary_provider_from_configs_pure(const std::string& env_string,
                                                                                         View<std::string> args);
}
