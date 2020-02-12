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
        virtual RestoreResult try_restore(const VcpkgPaths& paths,
                                          const PackageSpec& spec,
                                          const Build::AbiTagAndFile& abi_tag_and_file,
                                          const Build::BuildPackageOptions& build_options) = 0;
        virtual void push_success(const VcpkgPaths& paths,
                                  const Build::AbiTagAndFile& abi_tag_and_file,
                                  const Dependencies::InstallPlanAction& action) = 0;
        virtual void push_failure(const VcpkgPaths& paths,
                                  const Build::AbiTagAndFile& abi_tag_and_file,
                                  const PackageSpec& spec) = 0;
    };

    std::unique_ptr<IBinaryProvider> create_archives_provider();
}
