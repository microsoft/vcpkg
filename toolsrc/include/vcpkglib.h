#pragma once

#include "SortedVector.h"
#include "StatusParagraphs.h"
#include "VcpkgPaths.h"

namespace vcpkg
{
    extern bool g_debugging;

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
        CMakeVariable(const CWStringView varname, const wchar_t* varvalue);
        CMakeVariable(const CWStringView varname, const std::string& varvalue);
        CMakeVariable(const CWStringView varname, const std::wstring& varvalue);
        CMakeVariable(const CWStringView varname, const fs::path& path);

        std::wstring s;
    };

    std::wstring make_cmake_cmd(const fs::path& cmake_exe,
                                const fs::path& cmake_script,
                                const std::vector<CMakeVariable>& pass_variables);

    std::string shorten_text(const std::string& desc, size_t length);
} // namespace vcpkg
