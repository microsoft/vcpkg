#pragma once

#include <filesystem>
#include <unordered_map>

namespace vcpkg { namespace Paragraphs
{
    namespace fs = std::tr2::sys;
    std::vector<std::unordered_map<std::string, std::string>> get_paragraphs(const fs::path& control_path);
    std::vector<std::unordered_map<std::string, std::string>> parse_paragraphs(const std::string& str);
}}
