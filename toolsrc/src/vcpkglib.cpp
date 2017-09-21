#include "pch.h"

#include "Paragraphs.h"
#include "metrics.h"
#include "vcpkg_Files.h"
#include "vcpkg_Strings.h"
#include "vcpkg_Util.h"
#include "vcpkglib.h"

namespace vcpkg
{
    static StatusParagraphs load_current_database(Files::Filesystem& fs,
                                                  const fs::path& vcpkg_dir_status_file,
                                                  const fs::path& vcpkg_dir_status_file_old)
    {
        if (!fs.exists(vcpkg_dir_status_file))
        {
            if (!fs.exists(vcpkg_dir_status_file_old))
            {
                // no status file, use empty db
                return StatusParagraphs();
            }

            fs.rename(vcpkg_dir_status_file_old, vcpkg_dir_status_file);
        }

        auto pghs = Paragraphs::get_paragraphs(fs, vcpkg_dir_status_file).value_or_exit(VCPKG_LINE_INFO);

        std::vector<std::unique_ptr<StatusParagraph>> status_pghs;
        for (auto&& p : pghs)
        {
            status_pghs.push_back(std::make_unique<StatusParagraph>(std::move(p)));
        }

        return StatusParagraphs(std::move(status_pghs));
    }

    StatusParagraphs database_load_check(const VcpkgPaths& paths)
    {
        auto& fs = paths.get_filesystem();

        const auto updates_dir = paths.vcpkg_dir_updates;

        std::error_code ec;
        fs.create_directory(paths.installed, ec);
        fs.create_directory(paths.vcpkg_dir, ec);
        fs.create_directory(paths.vcpkg_dir_info, ec);
        fs.create_directory(updates_dir, ec);

        const fs::path& status_file = paths.vcpkg_dir_status_file;
        const fs::path status_file_old = status_file.parent_path() / "status-old";
        const fs::path status_file_new = status_file.parent_path() / "status-new";

        StatusParagraphs current_status_db = load_current_database(fs, status_file, status_file_old);

        auto update_files = fs.get_files_non_recursive(updates_dir);
        if (update_files.empty())
        {
            // updates directory is empty, control file is up-to-date.
            return current_status_db;
        }
        for (auto&& file : update_files)
        {
            if (!fs.is_regular_file(file)) continue;
            if (file.filename() == "incomplete") continue;

            auto pghs = Paragraphs::get_paragraphs(fs, file).value_or_exit(VCPKG_LINE_INFO);
            for (auto&& p : pghs)
            {
                current_status_db.insert(std::make_unique<StatusParagraph>(std::move(p)));
            }
        }

        fs.write_contents(status_file_new, Strings::serialize(current_status_db));

        fs.rename(status_file_new, status_file);

        for (auto&& file : update_files)
        {
            if (!fs.is_regular_file(file)) continue;

            fs.remove(file);
        }

        return current_status_db;
    }

    void write_update(const VcpkgPaths& paths, const StatusParagraph& p)
    {
        static int update_id = 0;
        auto& fs = paths.get_filesystem();

        const auto my_update_id = update_id++;
        const auto tmp_update_filename = paths.vcpkg_dir_updates / "incomplete";
        const auto update_filename = paths.vcpkg_dir_updates / std::to_string(my_update_id);

        fs.write_contents(tmp_update_filename, Strings::serialize(p));
        fs.rename(tmp_update_filename, update_filename);
    }

    static void upgrade_to_slash_terminated_sorted_format(Files::Filesystem& fs,
                                                          std::vector<std::string>* lines,
                                                          const fs::path& listfile_path)
    {
        static bool was_tracked = false;

        if (lines->empty())
        {
            return;
        }

        if (lines->at(0).back() == '/')
        {
            return; // File already in the new format
        }

        if (!was_tracked)
        {
            was_tracked = true;
            Metrics::g_metrics.lock()->track_property("listfile", "update to new format");
        }

        // The files are sorted such that directories are placed just before the files they contain
        // (They are not necessarily sorted alphabetically, e.g. libflac)
        // Therefore we can detect the entries that represent directories by comparing every element with the next one
        // and checking if the next has a slash immediately after the current one's length
        for (size_t i = 0; i < lines->size() - 1; i++)
        {
            std::string& current_string = lines->at(i);
            const std::string& next_string = lines->at(i + 1);

            const size_t potential_slash_char_index = current_string.length();
            // Make sure the index exists first
            if (next_string.size() > potential_slash_char_index && next_string.at(potential_slash_char_index) == '/')
            {
                current_string += '/'; // Mark as a directory
            }
        }

        // After suffixing the directories with a slash, we can now sort.
        // We cannot sort before adding the suffixes because the following (actual example):
        /*
            x86-windows/include/FLAC <<<<<< This would be separated from its group due to sorting
            x86-windows/include/FLAC/all.h
            x86-windows/include/FLAC/assert.h
            x86-windows/include/FLAC/callback.h
            x86-windows/include/FLAC++
            x86-windows/include/FLAC++/all.h
            x86-windows/include/FLAC++/decoder.h
            x86-windows/include/FLAC++/encoder.h
         *
            x86-windows/include/FLAC/ <<<<<< This will now be kept with its group when sorting
            x86-windows/include/FLAC/all.h
            x86-windows/include/FLAC/assert.h
            x86-windows/include/FLAC/callback.h
            x86-windows/include/FLAC++/
            x86-windows/include/FLAC++/all.h
            x86-windows/include/FLAC++/decoder.h
            x86-windows/include/FLAC++/encoder.h
        */
        // Note that after sorting, the FLAC++/ group will be placed before the FLAC/ group
        // The new format is lexicographically sorted
        std::sort(lines->begin(), lines->end());

        // Replace the listfile on disk
        const fs::path updated_listfile_path = listfile_path.generic_string() + "_updated";
        fs.write_lines(updated_listfile_path, *lines);
        fs.rename(updated_listfile_path, listfile_path);
    }

    std::vector<StatusParagraph*> get_installed_ports(const StatusParagraphs& status_db)
    {
        std::vector<StatusParagraph*> installed_packages;
        for (auto&& pgh : status_db)
        {
            if (pgh->state != InstallState::INSTALLED || pgh->want != Want::INSTALL) continue;
            installed_packages.push_back(pgh.get());
        }

        return installed_packages;
    }

    std::vector<StatusParagraphAndAssociatedFiles> get_installed_files(const VcpkgPaths& paths,
                                                                       const StatusParagraphs& status_db)
    {
        auto& fs = paths.get_filesystem();

        std::vector<StatusParagraphAndAssociatedFiles> installed_files;

        for (const std::unique_ptr<StatusParagraph>& pgh : status_db)
        {
            if (pgh->state != InstallState::INSTALLED || !pgh->package.feature.empty())
            {
                continue;
            }

            const fs::path listfile_path = paths.listfile_path(pgh->package);
            std::vector<std::string> installed_files_of_current_pgh =
                fs.read_lines(listfile_path).value_or_exit(VCPKG_LINE_INFO);
            Strings::trim_all_and_remove_whitespace_strings(&installed_files_of_current_pgh);
            upgrade_to_slash_terminated_sorted_format(fs, &installed_files_of_current_pgh, listfile_path);

            // Remove the directories
            Util::erase_remove_if(installed_files_of_current_pgh,
                                  [](const std::string& file) { return file.back() == '/'; });

            StatusParagraphAndAssociatedFiles pgh_and_files = {
                *pgh, SortedVector<std::string>(std::move(installed_files_of_current_pgh))};
            installed_files.push_back(std::move(pgh_and_files));
        }

        return installed_files;
    }

    CMakeVariable::CMakeVariable(const CWStringView varname, const wchar_t* varvalue)
        : s(Strings::wformat(LR"("-D%s=%s")", varname, varvalue))
    {
    }
    CMakeVariable::CMakeVariable(const CWStringView varname, const std::string& varvalue)
        : CMakeVariable(varname, Strings::to_utf16(varvalue).c_str())
    {
    }
    CMakeVariable::CMakeVariable(const CWStringView varname, const std::wstring& varvalue)
        : CMakeVariable(varname, varvalue.c_str())
    {
    }
    CMakeVariable::CMakeVariable(const CWStringView varname, const fs::path& path)
        : CMakeVariable(varname, path.generic_wstring())
    {
    }

    std::wstring make_cmake_cmd(const fs::path& cmake_exe,
                                const fs::path& cmake_script,
                                const std::vector<CMakeVariable>& pass_variables)
    {
        const std::wstring cmd_cmake_pass_variables = Strings::join(L" ", pass_variables, [](auto&& v) { return v.s; });
        return Strings::wformat(
            LR"("%s" %s -P "%s")", cmake_exe.native(), cmd_cmake_pass_variables, cmake_script.generic_wstring());
    }

    std::string shorten_text(const std::string& desc, size_t length)
    {
        Checks::check_exit(VCPKG_LINE_INFO, length >= 3);
        auto simple_desc = std::regex_replace(desc, std::regex("\\s+"), " ");
        return simple_desc.size() <= length ? simple_desc : simple_desc.substr(0, length - 3) + "...";
    }
}
