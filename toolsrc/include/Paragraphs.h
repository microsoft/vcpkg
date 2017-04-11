#pragma once

#include "filesystem_fs.h"
#include <map>
#include "vcpkg_expected.h"
#include "BinaryParagraph.h"
#include "VcpkgPaths.h"
#include "VersionT.h"

namespace vcpkg::Paragraphs
{
    using ParagraphDataMap = std::unordered_map<std::string, std::string>;

    Expected<ParagraphDataMap> get_single_paragraph(const fs::path& control_path);
    Expected<std::vector<ParagraphDataMap>> get_paragraphs(const fs::path& control_path);
    Expected<ParagraphDataMap> parse_single_paragraph(const std::string& str);
    Expected<std::vector<ParagraphDataMap>> parse_paragraphs(const std::string& str);

    Expected<SourceParagraph> try_load_port(const fs::path& control_path);

    Expected<BinaryParagraph> try_load_cached_package(const VcpkgPaths& paths, const PackageSpec& spec);

    std::vector<SourceParagraph> load_all_ports(const fs::path& ports_dir);

    std::map<std::string, VersionT> extract_port_names_and_versions(const std::vector<SourceParagraph>& source_paragraphs);
}
