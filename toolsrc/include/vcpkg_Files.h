#pragma once

#include "expected.h"
#include <filesystem>
#include <iterator>

namespace vcpkg {namespace Files
{
    namespace fs = std::tr2::sys;

    static const char* FILESYSTEM_INVALID_CHARACTERS = R"(\/:*?"<>|)";

    void check_is_directory(const std::tr2::sys::path& dirpath);

    bool has_invalid_chars_for_filesystem(const std::string s);

    expected<std::string> get_contents(const std::tr2::sys::path& file_path) noexcept;

    std::tr2::sys::path find_file_recursively_up(const std::tr2::sys::path& starting_dir, const std::string& filename);

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
}}
