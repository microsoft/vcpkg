#pragma once

#include "expected.h"
#include <filesystem>

namespace vcpkg {namespace Files
{
    static const char* FILESYSTEM_INVALID_CHARACTERS = R"(\/:*?"<>|)";

    void check_is_directory(const std::tr2::sys::path& dirpath);

    bool has_invalid_chars_for_filesystem(const std::string s);

    expected<std::string> get_contents(const std::tr2::sys::path& file_path) noexcept;

    std::tr2::sys::path find_file_recursively_up(const std::tr2::sys::path& starting_dir, const std::string& filename);
}}
