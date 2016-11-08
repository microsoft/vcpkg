#pragma once

#include <filesystem>
#include <unordered_map>
#include "package_spec.h"
#include "BinaryParagraph.h"
#include "StatusParagraphs.h"
#include "vcpkg_paths.h"

namespace vcpkg
{
    namespace fs = std::tr2::sys;

    extern bool g_do_dry_run;

    StatusParagraphs database_load_check(const vcpkg_paths& paths);

    void install_package(const vcpkg_paths& paths, const BinaryParagraph& binary_paragraph, StatusParagraphs& status_db);
    void deinstall_package(const vcpkg_paths& paths, const package_spec& spec, StatusParagraphs& status_db);

    void search_file(const vcpkg_paths& paths, const std::string& file_substr, const StatusParagraphs& status_db);
} // namespace vcpkg
