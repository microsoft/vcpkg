#include "pch.h"
#include "vcpkglib.h"
#include "vcpkg_Files.h"
#include "Paragraphs.h"
#include "metrics.h"

namespace vcpkg
{
    static StatusParagraphs load_current_database(const fs::path& vcpkg_dir_status_file, const fs::path& vcpkg_dir_status_file_old)
    {
        if (!fs::exists(vcpkg_dir_status_file))
        {
            if (!fs::exists(vcpkg_dir_status_file_old))
            {
                // no status file, use empty db
                return StatusParagraphs();
            }

            fs::rename(vcpkg_dir_status_file_old, vcpkg_dir_status_file);
        }

        auto text = Files::read_contents(vcpkg_dir_status_file).get_or_throw();
        auto pghs = Paragraphs::parse_paragraphs(text);

        std::vector<std::unique_ptr<StatusParagraph>> status_pghs;
        for (auto&& p : pghs)
        {
            status_pghs.push_back(std::make_unique<StatusParagraph>(p));
        }

        return StatusParagraphs(std::move(status_pghs));
    }

    StatusParagraphs database_load_check(const vcpkg_paths& paths)
    {
        auto updates_dir = paths.vcpkg_dir_updates;

        std::error_code ec;
        fs::create_directory(paths.installed, ec);
        fs::create_directory(paths.vcpkg_dir, ec);
        fs::create_directory(paths.vcpkg_dir_info, ec);
        fs::create_directory(updates_dir, ec);

        const fs::path& status_file = paths.vcpkg_dir_status_file;
        const fs::path status_file_old = status_file.parent_path() / "status-old";
        const fs::path status_file_new = status_file.parent_path() / "status-new";

        StatusParagraphs current_status_db = load_current_database(status_file, status_file_old);

        auto b = fs::directory_iterator(updates_dir);
        auto e = fs::directory_iterator();
        if (b == e)
        {
            // updates directory is empty, control file is up-to-date.
            return current_status_db;
        }

        for (; b != e; ++b)
        {
            if (!fs::is_regular_file(b->status()))
                continue;
            if (b->path().filename() == "incomplete")
                continue;

            auto text = Files::read_contents(b->path()).get_or_throw();
            auto pghs = Paragraphs::parse_paragraphs(text);
            for (auto&& p : pghs)
            {
                current_status_db.insert(std::make_unique<StatusParagraph>(p));
            }
        }

        std::fstream(status_file_new, std::ios_base::out | std::ios_base::binary | std::ios_base::trunc) << current_status_db;

        if (fs::exists(status_file_old))
            fs::remove(status_file_old);
        if (fs::exists(status_file))
            fs::rename(status_file, status_file_old);
        fs::rename(status_file_new, status_file);
        fs::remove(status_file_old);

        b = fs::directory_iterator(updates_dir);
        for (; b != e; ++b)
        {
            if (!fs::is_regular_file(b->status()))
                continue;
            fs::remove(b->path());
        }

        return current_status_db;
    }

    void write_update(const vcpkg_paths& paths, const StatusParagraph& p)
    {
        static int update_id = 0;
        auto my_update_id = update_id++;
        auto tmp_update_filename = paths.vcpkg_dir_updates / "incomplete";
        auto update_filename = paths.vcpkg_dir_updates / std::to_string(my_update_id);
        std::fstream fs(tmp_update_filename, std::ios_base::out | std::ios_base::binary | std::ios_base::trunc);
        fs << p;
        fs.close();
        fs::rename(tmp_update_filename, update_filename);
    }

    static void upgrade_to_slash_terminated_sorted_format(std::vector<std::string>* lines, const fs::path& listfile_path)
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
            TrackProperty("listfile", "update to new format");
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
        Files::write_all_lines(updated_listfile_path, *lines);
        fs::rename(updated_listfile_path, listfile_path);
    }

    std::vector<StatusParagraph_and_associated_files> get_installed_files(const vcpkg_paths& paths, const StatusParagraphs& status_db)
    {
        std::vector<StatusParagraph_and_associated_files> installed_files;

        for (const std::unique_ptr<StatusParagraph>& pgh : status_db)
        {
            if (pgh->state != install_state_t::installed)
            {
                continue;
            }

            const fs::path listfile_path = paths.listfile_path(pgh->package);
            std::vector<std::string> installed_files_of_current_pgh = Files::read_all_lines(listfile_path).get_or_throw();
            Strings::trim_all_and_remove_whitespace_strings(&installed_files_of_current_pgh);
            upgrade_to_slash_terminated_sorted_format(&installed_files_of_current_pgh, listfile_path);

            // Remove the directories
            installed_files_of_current_pgh.erase(
                std::remove_if(installed_files_of_current_pgh.begin(), installed_files_of_current_pgh.end(), [](const std::string& file) -> bool
                               {
                                   return file.back() == '/';
                               }
                ), installed_files_of_current_pgh.end());

            StatusParagraph_and_associated_files pgh_and_files = { *pgh, ImmutableSortedVector<std::string>::create(std::move(installed_files_of_current_pgh)) };
            installed_files.push_back(std::move(pgh_and_files));
        }

        return installed_files;
    }

    expected<SourceParagraph> try_load_port(const fs::path& path)
    {
        try
        {
            auto pghs = Paragraphs::get_paragraphs(path / "CONTROL");
            Checks::check_exit(pghs.size() == 1, "Invalid control file at %s\\CONTROL", path.string());
            return SourceParagraph(pghs[0]);
        }
        catch (std::runtime_error const&) { }

        return std::errc::no_such_file_or_directory;
    }

    expected<BinaryParagraph> try_load_cached_package(const vcpkg_paths& paths, const package_spec& spec)
    {
        const fs::path path = paths.package_dir(spec) / "CONTROL";

        auto control_contents_maybe = Files::read_contents(path);
        if (auto control_contents = control_contents_maybe.get())
        {
            std::vector<std::unordered_map<std::string, std::string>> pghs;
            try
            {
                pghs = Paragraphs::parse_paragraphs(*control_contents);
            }
            catch (std::runtime_error) { }
            Checks::check_exit(pghs.size() == 1, "Invalid control file at %s", path.string());
            return BinaryParagraph(pghs[0]);
        }
        return control_contents_maybe.error_code();
    }

    std::vector<SourceParagraph> load_all_ports(const fs::path& ports_dir)
    {
        std::vector<SourceParagraph> output;
        for (auto it = fs::directory_iterator(ports_dir); it != fs::directory_iterator(); ++it)
        {
            const fs::path& path = it->path();
            expected<SourceParagraph> source_paragraph = try_load_port(path);
            if (auto srcpgh = source_paragraph.get())
            {
                output.emplace_back(*srcpgh);
            }
            else
            {
                Checks::exit_with_message("Error loading port from %s: %s", path.generic_string(), source_paragraph.error_code().message());
            }
        }

        return output;
    }
}
