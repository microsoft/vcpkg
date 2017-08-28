#pragma once

#include "vcpkg_Files.h"
#include "vcpkg_Dependencies.h"

namespace vcpkg::Commands::Export::IFW
{
    fs::path export_real_package(const fs::path &raw_exported_dir_path, const Dependencies::ExportPlanAction& action, Files::Filesystem& fs);
    void export_unique_packages(const fs::path &raw_exported_dir_path, std::map<std::string, const Dependencies::ExportPlanAction*> unique_packages, Files::Filesystem& fs);
    void export_unique_triplets(const fs::path &raw_exported_dir_path, std::set<std::string> unique_triplets, Files::Filesystem& fs);
    void export_integration(const fs::path &raw_exported_dir_path, Files::Filesystem& fs);
    void export_config(const fs::path &raw_exported_dir_path, const std::string ifw_repository_url, Files::Filesystem& fs);
}
