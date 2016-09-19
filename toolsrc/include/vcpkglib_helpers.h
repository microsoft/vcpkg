#pragma once

#include <unordered_map>

namespace vcpkg {namespace details
{
    void optional_field(const std::unordered_map<std::string, std::string>& fields, std::string& out, const std::string& fieldname);

    void required_field(const std::unordered_map<std::string, std::string>& fields, std::string& out, const std::string& fieldname);

    void parse_depends(const std::string& depends_string, std::vector<std::string>& out);
}}
