#pragma once

#include "filesystem_fs.h"
#include <unordered_map>

namespace vcpkg::Paragraphs
{
    std::vector<std::unordered_map<std::string, std::string>> get_paragraphs(const fs::path& control_path);
    std::vector<std::unordered_map<std::string, std::string>> parse_paragraphs(const std::string& str);
}
