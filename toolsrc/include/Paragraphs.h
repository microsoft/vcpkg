#pragma once

#include "filesystem_fs.h"
#include <unordered_map>
#include "expected.h"
#include "BinaryParagraph.h"
#include "vcpkg_paths.h"

namespace vcpkg::Paragraphs
{
    std::vector<std::unordered_map<std::string, std::string>> get_paragraphs(const fs::path& control_path);
    std::vector<std::unordered_map<std::string, std::string>> parse_paragraphs(const std::string& str);

    expected<SourceParagraph> try_load_port(const fs::path& control_path);

    expected<BinaryParagraph> try_load_cached_package(const vcpkg_paths& paths, const package_spec& spec);

    std::vector<SourceParagraph> load_all_ports(const fs::path& ports_dir);
}
