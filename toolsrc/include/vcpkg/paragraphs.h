#pragma once

#include <vcpkg/base/expected.h>

#include <vcpkg/binaryparagraph.h>
#include <vcpkg/paragraphparser.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::Paragraphs
{
    using Paragraph = Parse::Paragraph;

    ExpectedS<Paragraph> parse_single_paragraph(const std::string& str, const std::string& origin);
    ExpectedS<Paragraph> get_single_paragraph(const Files::Filesystem& fs, const fs::path& control_path);
    ExpectedS<std::vector<Paragraph>> get_paragraphs(const Files::Filesystem& fs, const fs::path& control_path);
    ExpectedS<std::vector<Paragraph>> parse_paragraphs(const std::string& str, const std::string& origin);

    bool is_port_directory(const Files::Filesystem& fs, const fs::path& path);

    Parse::ParseExpected<SourceControlFile> try_load_port(const Files::Filesystem& fs, const fs::path& path);

    ExpectedS<BinaryControlFile> try_load_cached_package(const VcpkgPaths& paths, const PackageSpec& spec);

    struct LoadResults
    {
        std::vector<SourceControlFileLocation> paragraphs;
        std::vector<std::unique_ptr<Parse::ParseControlErrorInfo>> errors;
    };

    LoadResults try_load_all_ports(const VcpkgPaths& paths);

    std::vector<SourceControlFileLocation> load_all_ports(const VcpkgPaths& paths);
    std::vector<SourceControlFileLocation> load_overlay_ports(const VcpkgPaths& paths, const fs::path& dir);
}
