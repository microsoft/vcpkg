#pragma once

#include <vcpkg/dependencies.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/vcpkgpaths.h>

#include <string>

namespace vcpkg
{
    std::string reformat_version(const std::string& version, const std::string& abi_tag);

    struct NugetReference
    {
        explicit NugetReference(const Dependencies::InstallPlanAction& action)
            : NugetReference(action.spec,
                             action.source_control_file_location.value_or_exit(VCPKG_LINE_INFO)
                                 .source_control_file->core_paragraph->version,
                             action.abi_info.value_or_exit(VCPKG_LINE_INFO).package_abi)
        {
        }

        NugetReference(const PackageSpec& spec, const std::string& raw_version, const std::string& abi_tag)
            : id(spec.dir()), version(reformat_version(raw_version, abi_tag))
        {
        }

        std::string id;
        std::string version;

        std::string nupkg_filename() const { return Strings::concat(id, '.', version, ".nupkg"); }
    };

    namespace details
    {
        struct NuGetRepoInfo
        {
            std::string repo;
            std::string branch;
            std::string commit;
        };

        NuGetRepoInfo get_nuget_repo_info_from_env();
    }

    std::string generate_nuspec(const VcpkgPaths& paths,
                                const Dependencies::InstallPlanAction& action,
                                const NugetReference& ref,
                                details::NuGetRepoInfo rinfo = details::get_nuget_repo_info_from_env());

    struct XmlSerializer
    {
        XmlSerializer& emit_declaration();
        XmlSerializer& open_tag(StringLiteral sl);
        XmlSerializer& start_complex_open_tag(StringLiteral sl);
        XmlSerializer& text_attr(StringLiteral name, StringView content);
        XmlSerializer& finish_complex_open_tag();
        XmlSerializer& finish_self_closing_complex_tag();
        XmlSerializer& close_tag(StringLiteral sl);
        XmlSerializer& text(StringView sv);
        XmlSerializer& simple_tag(StringLiteral tag, StringView content);
        XmlSerializer& line_break();

        std::string buf;

    private:
        XmlSerializer& emit_pending_indent();

        int m_indent = 0;
        bool m_pending_indent = false;
    };

}
