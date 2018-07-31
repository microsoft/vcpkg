#pragma once

#include <vcpkg/base/files.h>

#include <string>

namespace vcpkg::Hash
{
    std::string get_string_hash(const std::string& s, const std::string& hash_type);
    std::string get_file_hash(const Files::Filesystem& fs, const fs::path& path, const std::string& hash_type);
}
