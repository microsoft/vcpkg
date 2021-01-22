#pragma once

#include <vcpkg/fwd/vcpkgpaths.h>

#include <vcpkg/base/expected.h>

#include <vcpkg/binaryparagraph.h>

namespace vckpg::Parse
{
    struct ParseControlErrorInfo;
}

namespace vcpkg::Paragraphs
{
    using Paragraph = Parse::Paragraph;

    ExpectedS<Paragraph> parse_single_paragraph(const std::string& str, const std::string& origin);
    ExpectedS<Paragraph> get_single_paragraph(const Files::Filesystem& fs, const fs::path& control_path);

    ExpectedS<std::vector<Paragraph>> get_paragraphs(const Files::Filesystem& fs, const fs::path& control_path);
    ExpectedS<std::vector<Paragraph>> get_paragraphs_text(const std::string& text, const std::string& origin);

    ExpectedS<std::vector<Paragraph>> parse_paragraphs(const std::string& str, const std::string& origin);

    bool is_port_directory(const Files::Filesystem& fs, const fs::path& path);

    Parse::ParseExpected<SourceControlFile> try_load_port(const Files::Filesystem& fs, const fs::path& path);
    Parse::ParseExpected<SourceControlFile> try_load_port_text(const std::string& text,
                                                               const std::string& origin,
                                                               bool is_manifest);

    ExpectedS<BinaryControlFile> try_load_cached_package(const VcpkgPaths& paths, const PackageSpec& spec);

    struct LoadResults
    {
        std::vector<SourceControlFileLocation> paragraphs;
        std::vector<std::unique_ptr<Parse::ParseControlErrorInfo>> errors;
    };

    // this allows one to pass this around as an overload set to stuff like `Util::fmap`,
    // as opposed to making it a function
    constexpr struct
    {
        const std::string& operator()(const SourceControlFileLocation* loc) const
        {
            return (*this)(*loc->source_control_file);
        }
        const std::string& operator()(const SourceControlFileLocation& loc) const
        {
            return (*this)(*loc.source_control_file);
        }
        const std::string& operator()(const SourceControlFile& scf) const { return scf.core_paragraph->name; }
    } get_name_of_control_file;

    LoadResults try_load_all_registry_ports(const VcpkgPaths& paths);

    std::vector<SourceControlFileLocation> load_all_registry_ports(const VcpkgPaths& paths);
    std::vector<SourceControlFileLocation> load_overlay_ports(const Files::Filesystem& fs, const fs::path& dir);
}
