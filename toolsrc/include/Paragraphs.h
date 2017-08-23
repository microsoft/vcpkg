#pragma once

#include <map>

#include "BinaryParagraph.h"
#include "VcpkgPaths.h"
#include "VersionT.h"
#include "filesystem_fs.h"
#include "vcpkg_Parse.h"
#include "vcpkg_expected.h"

namespace vcpkg::Paragraphs
{
    using RawParagraph = Parse::RawParagraph;

    Expected<RawParagraph> get_single_paragraph(const Files::Filesystem& fs, const fs::path& control_path);
    Expected<std::vector<RawParagraph>> get_paragraphs(const Files::Filesystem& fs, const fs::path& control_path);
    Expected<RawParagraph> parse_single_paragraph(const std::string& str);
    Expected<std::vector<RawParagraph>> parse_paragraphs(const std::string& str);

    Parse::ParseExpected<SourceControlFile> try_load_port(const Files::Filesystem& fs, const fs::path& control_path);

    Expected<BinaryControlFile> try_load_cached_control_package(const VcpkgPaths& paths, const PackageSpec& spec);

    struct LoadResults
    {
        std::vector<std::unique_ptr<SourceControlFile>> paragraphs;
        std::vector<std::unique_ptr<Parse::ParseControlErrorInfo>> errors;
    };

    LoadResults try_load_all_ports(const Files::Filesystem& fs, const fs::path& ports_dir);

    std::vector<std::unique_ptr<SourceControlFile>> load_all_ports(const Files::Filesystem& fs,
                                                                   const fs::path& ports_dir);

    std::map<std::string, VersionT> load_all_port_names_and_versions(const Files::Filesystem& fs,
                                                                     const fs::path& ports_dir);
}
