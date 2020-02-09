#pragma once

#include <vcpkg/binaryparagraph.h>
#include <vcpkg/paragraphparser.h>
#include <vcpkg/vcpkgpaths.h>

#include <vcpkg/base/expected.h>

namespace vcpkg::Paragraphs
{
    using RawParagraph = Parse::RawParagraph;

    ExpectedS<RawParagraph> get_single_paragraph(const Files::Filesystem& fs, const fs::path& control_path);
    ExpectedS<std::vector<RawParagraph>> get_paragraphs(const Files::Filesystem& fs, const fs::path& control_path);
    ExpectedS<std::vector<RawParagraph>> parse_paragraphs(const std::string& str, const std::string& origin);

    Parse::ParseExpected<SourceControlFile> try_load_port(const Files::Filesystem& fs, const fs::path& control_path);

    ExpectedS<BinaryControlFile> try_load_cached_package(const VcpkgPaths& paths, const PackageSpec& spec);

    struct LoadResults
    {
        std::vector<std::unique_ptr<SourceControlFile>> paragraphs;
        std::vector<std::unique_ptr<Parse::ParseControlErrorInfo>> errors;
    };

    LoadResults try_load_all_ports(const Files::Filesystem& fs, const fs::path& ports_dir);

    std::vector<std::unique_ptr<SourceControlFile>> load_all_ports(const Files::Filesystem& fs,
                                                                   const fs::path& ports_dir);
}
