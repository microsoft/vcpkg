#pragma once

#include <vcpkg/base/sortedvector.h>
#include <vcpkg/statusparagraphs.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg
{
    StatusParagraphs database_load_check(const VcpkgPaths& paths);

    void write_update(const VcpkgPaths& paths, const StatusParagraph& p);

    struct StatusParagraphAndAssociatedFiles
    {
        StatusParagraph pgh;
        SortedVector<std::string> files;
    };

    std::vector<StatusParagraph*> get_installed_ports(const StatusParagraphs& status_db);
    std::vector<StatusParagraphAndAssociatedFiles> get_installed_files(const VcpkgPaths& paths,
                                                                       const StatusParagraphs& status_db);

    struct CMakeVariable
    {
        CMakeVariable(const CStringView varname, const char* varvalue);
        CMakeVariable(const CStringView varname, const std::string& varvalue);
        CMakeVariable(const CStringView varname, const fs::path& path);

        std::string s;
    };

    std::string make_cmake_cmd(const fs::path& cmake_exe,
                               const fs::path& cmake_script,
                               const std::vector<CMakeVariable>& pass_variables);

    std::string shorten_text(const std::string& desc, size_t length);
} // namespace vcpkg
