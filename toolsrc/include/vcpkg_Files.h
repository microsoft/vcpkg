#pragma once

#include "expected.h"
#include "filesystem_fs.h"
#include <iterator>

namespace vcpkg {namespace Files
{
    static const char* FILESYSTEM_INVALID_CHARACTERS = R"(\/:*?"<>|)";

    void check_is_directory(const fs::path& dirpath);

    bool has_invalid_chars_for_filesystem(const std::string& s);

    expected<std::string> read_contents(const fs::path& file_path) noexcept;

    expected<std::vector<std::string>> read_all_lines(const fs::path& file_path);

    void write_all_lines(const fs::path& file_path, const std::vector<std::string>& lines);

    fs::path find_file_recursively_up(const fs::path& starting_dir, const std::string& filename);

    template <class Pred>
    void non_recursive_find_matching_paths_in_dir(const fs::path& dir, const Pred predicate, std::vector<fs::path>* output)
    {
        std::copy_if(fs::directory_iterator(dir), fs::directory_iterator(), std::back_inserter(*output), predicate);
    }

    template <class Pred>
    void recursive_find_matching_paths_in_dir(const fs::path& dir, const Pred predicate, std::vector<fs::path>* output)
    {
        std::copy_if(fs::recursive_directory_iterator(dir), fs::recursive_directory_iterator(), std::back_inserter(*output), predicate);
    }

    template <class Pred>
    std::vector<fs::path> recursive_find_matching_paths_in_dir(const fs::path& dir, const Pred predicate)
    {
        std::vector<fs::path> v;
        recursive_find_matching_paths_in_dir(dir, predicate, &v);
        return v;
    }

    void recursive_find_files_with_extension_in_dir(const fs::path& dir, const std::string& extension, std::vector<fs::path>* output);

    std::vector<fs::path> recursive_find_files_with_extension_in_dir(const fs::path& dir, const std::string& extension);

    void recursive_find_all_files_in_dir(const fs::path& dir, std::vector<fs::path>* output);

    std::vector<fs::path> recursive_find_all_files_in_dir(const fs::path& dir);

    void non_recursive_find_all_files_in_dir(const fs::path& dir, std::vector<fs::path>* output);

    std::vector<fs::path> non_recursive_find_all_files_in_dir(const fs::path& dir);

    void print_paths(const std::vector<fs::path>& paths);
}}
