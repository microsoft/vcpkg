#pragma once

#include <vcpkg/fwd/vcpkgpaths.h>

#include <vcpkg/dependencies.h>

#include <string>
#include <vector>

namespace vcpkg::Export::IFW
{
    struct Options
    {
        Optional<std::string> maybe_repository_url;
        Optional<std::string> maybe_packages_dir_path;
        Optional<std::string> maybe_repository_dir_path;
        Optional<std::string> maybe_config_file_path;
        Optional<std::string> maybe_installer_file_path;
    };

    void do_export(const std::vector<Dependencies::ExportPlanAction>& export_plan,
                   const std::string& export_id,
                   const Options& ifw_options,
                   const VcpkgPaths& paths);
}
