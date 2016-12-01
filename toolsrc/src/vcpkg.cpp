#include "vcpkg.h"
#include <iostream>
#include <iomanip>
#include <fstream>
#include <functional>
#include <string>
#include <unordered_map>
#include <memory>
#include <vector>
#include "vcpkg_Files.h"
#include "Paragraphs.h"
#include <regex>

using namespace vcpkg;

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

    auto text = Files::get_contents(vcpkg_dir_status_file).get_or_throw();
    auto pghs = Paragraphs::parse_paragraphs(text);

    std::vector<std::unique_ptr<StatusParagraph>> status_pghs;
    for (auto&& p : pghs)
    {
        status_pghs.push_back(std::make_unique<StatusParagraph>(p));
    }

    return StatusParagraphs(std::move(status_pghs));
}

StatusParagraphs vcpkg::database_load_check(const vcpkg_paths& paths)
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

        auto text = Files::get_contents(b->path()).get_or_throw();
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

void vcpkg::write_update(const vcpkg_paths& paths, const StatusParagraph& p)
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

expected<SourceParagraph> vcpkg::try_load_port(const fs::path& path)
{
    try
    {
        auto pghs = Paragraphs::get_paragraphs(path / "CONTROL");
        Checks::check_exit(pghs.size() == 1, "Invalid control file at %s\\CONTROL", path.string());
        return SourceParagraph(pghs[0]);
    }
    catch (std::runtime_error const&)
    {
    }

    return std::errc::no_such_file_or_directory;
}

expected<BinaryParagraph> vcpkg::try_load_cached_package(const vcpkg_paths& paths, const package_spec& spec)
{
    const fs::path path = paths.package_dir(spec) / "CONTROL";

    auto control_contents_maybe = Files::get_contents(path);
    if (auto control_contents = control_contents_maybe.get())
    {
        std::vector<std::unordered_map<std::string, std::string>> pghs;
        try
        {
            pghs = Paragraphs::parse_paragraphs(*control_contents);
        }
        catch (std::runtime_error)
        {
        }
        Checks::check_exit(pghs.size() == 1, "Invalid control file at %s", path.string());
        return BinaryParagraph(pghs[0]);
    }
    return control_contents_maybe.error_code();
}
