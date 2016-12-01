#pragma once

#include "package_spec.h"
#include "BinaryParagraph.h"
#include "StatusParagraphs.h"
#include "vcpkg_paths.h"

namespace vcpkg
{
    StatusParagraphs database_load_check(const vcpkg_paths& paths);

    void install_package(const vcpkg_paths& paths, const BinaryParagraph& binary_paragraph, StatusParagraphs& status_db);
    void deinstall_package(const vcpkg_paths& paths, const package_spec& spec, StatusParagraphs& status_db);

    expected<SourceParagraph> try_load_port(const fs::path& control_path);

    inline expected<SourceParagraph> try_load_port(const vcpkg_paths& paths, const std::string& name)
    {
        return try_load_port(paths.ports / name);
    }

    expected<BinaryParagraph> try_load_cached_package(const vcpkg_paths& paths, const package_spec& spec);
} // namespace vcpkg
