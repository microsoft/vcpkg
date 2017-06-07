#pragma once

#include "BinaryParagraph.h"
#include "VcpkgPaths.h"
#include "VersionT.h"
#include "filesystem_fs.h"
#include "vcpkg_expected.h"
#include <map>

namespace vcpkg::Paragraphs
{
    using ParagraphDataMap = std::unordered_map<std::string, std::string>;

    Expected<ParagraphDataMap> get_single_paragraph(const Files::Filesystem& fs, const fs::path& control_path);
    Expected<std::vector<ParagraphDataMap>> get_paragraphs(const Files::Filesystem& fs, const fs::path& control_path);
    Expected<ParagraphDataMap> parse_single_paragraph(const std::string& str);
    Expected<std::vector<ParagraphDataMap>> parse_paragraphs(const std::string& str);

    ExpectedT<SourceControlFile, ParseControlErrorInfo> try_load_port(const Files::Filesystem& fs,
                                                                      const fs::path& control_path);

    Expected<BinaryParagraph> try_load_cached_package(const VcpkgPaths& paths, const PackageSpec& spec);

    std::vector<SourceControlFile> load_all_ports(const Files::Filesystem& fs, const fs::path& ports_dir);

    std::map<std::string, VersionT> extract_port_names_and_versions(
        const std::vector<SourceParagraph>& source_paragraphs);
}
