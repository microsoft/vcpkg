#pragma once

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
    enum RestoreResult
    {
        MISSING,
        SUCCESS,
        BUILD_FAILED,
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

    std::unique_ptr<IBinaryProvider> create_archives_provider();
}
