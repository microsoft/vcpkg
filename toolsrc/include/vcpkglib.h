#pragma once

#include "StatusParagraphs.h"
#include "vcpkg_paths.h"
#include "ImmutableSortedVector.h"

namespace vcpkg
{
    extern bool g_debugging;

    StatusParagraphs database_load_check(const vcpkg_paths& paths);

    void write_update(const vcpkg_paths& paths, const StatusParagraph& p);

    struct StatusParagraph_and_associated_files
    {
        StatusParagraph pgh;
        ImmutableSortedVector<std::string> files;
    };

    std::vector<StatusParagraph_and_associated_files> get_installed_files(const vcpkg_paths& paths, const StatusParagraphs& status_db);


    struct CMakeVariable
    {
        CMakeVariable(const std::wstring& varname, const wchar_t* varvalue);
        CMakeVariable(const std::wstring& varname, const std::string& varvalue);
        CMakeVariable(const std::wstring& varname, const std::wstring& varvalue);
        CMakeVariable(const std::wstring& varname, const fs::path& path);

        std::wstring s;
    };

    std::wstring make_cmake_cmd(const fs::path& cmake_exe, const fs::path& cmake_script, const std::vector<CMakeVariable>& pass_variables);

} // namespace vcpkg
