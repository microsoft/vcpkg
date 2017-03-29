#pragma once

#include "filesystem_fs.h"
#include <map>
#include "vcpkg_expected.h"
#include "BinaryParagraph.h"
#include "vcpkg_paths.h"
#include "version_t.h"

namespace vcpkg::Paragraphs
{
    expected<std::unordered_map<std::string, std::string>> get_single_paragraph(const fs::path& control_path);
    expected<std::vector<std::unordered_map<std::string, std::string>>> get_paragraphs(const fs::path& control_path);
    expected<std::unordered_map<std::string, std::string>> parse_single_paragraph(const std::string& str);
    expected<std::vector<std::unordered_map<std::string, std::string>>> parse_paragraphs(const std::string& str);

    expected<SourceParagraph> try_load_port(const fs::path& control_path);

    expected<BinaryParagraph> try_load_cached_package(const vcpkg_paths& paths, const package_spec& spec);

    std::vector<SourceParagraph> load_all_ports(const fs::path& ports_dir);

    std::map<std::string, version_t> extract_port_names_and_versions(const std::vector<SourceParagraph>& source_paragraphs);
}
