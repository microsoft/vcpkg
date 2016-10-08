#pragma once

#include <filesystem>
#include <vector>
#include <unordered_map>
#include "package_spec.h"
#include "BinaryParagraph.h"
#include "StatusParagraphs.h"
#include "vcpkg_paths.h"

namespace vcpkg
{
    namespace fs = std::tr2::sys;

    extern bool g_do_dry_run;

    std::vector<std::unordered_map<std::string, std::string>> get_paragraphs(const fs::path& control_path);
    std::vector<std::unordered_map<std::string, std::string>> parse_paragraphs(const std::string& str);
    std::string shorten_description(const std::string& desc);

    StatusParagraphs database_load_check(const vcpkg_paths& paths);

    std::vector<std::string> get_unmet_package_dependencies(const vcpkg_paths& paths, const package_spec& spec, const StatusParagraphs& status_db);

    void install_package(const vcpkg_paths& paths, const BinaryParagraph& binary_paragraph, StatusParagraphs& status_db);
    void deinstall_package(const vcpkg_paths& paths, const package_spec& spec, StatusParagraphs& status_db);

    void search_file(const vcpkg_paths& paths, const std::string& file_substr, const StatusParagraphs& status_db);

    void binary_import(const vcpkg_paths& paths, const fs::path& include_directory, const fs::path& project_directory, const BinaryParagraph& control_file_data);

    const std::string& version();
} // namespace vcpkg
