#pragma once

#include "filesystem_fs.h"
#include <map>
#include "vcpkg_expected.h"
#include "BinaryParagraph.h"
#include "vcpkg_paths.h"
#include "version_t.h"

namespace vcpkg::Paragraphs
{
    using ParagraphDataMap = std::unordered_map<std::string, std::string>;

    expected<ParagraphDataMap> get_single_paragraph(const fs::path& control_path);
    expected<std::vector<ParagraphDataMap>> get_paragraphs(const fs::path& control_path);
    expected<ParagraphDataMap> parse_single_paragraph(const std::string& str);
    expected<std::vector<ParagraphDataMap>> parse_paragraphs(const std::string& str);

    expected<SourceParagraph> try_load_port(const fs::path& control_path);

    expected<BinaryParagraph> try_load_cached_package(const vcpkg_paths& paths, const PackageSpec& spec);

    std::vector<SourceParagraph> load_all_ports(const fs::path& ports_dir);

    std::map<std::string, version_t> extract_port_names_and_versions(const std::vector<SourceParagraph>& source_paragraphs);
}
