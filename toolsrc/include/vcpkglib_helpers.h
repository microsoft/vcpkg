#pragma once

#include <unordered_map>

namespace vcpkg::details
{
    std::string optional_field(const std::unordered_map<std::string, std::string>& fields,
                               const std::string& fieldname);
    std::string remove_optional_field(std::unordered_map<std::string, std::string>* fields,
                                      const std::string& fieldname);

    std::string required_field(const std::unordered_map<std::string, std::string>& fields,
                               const std::string& fieldname);
    std::string remove_required_field(std::unordered_map<std::string, std::string>* fields,
                                      const std::string& fieldname);

    std::string shorten_description(const std::string& desc);
}
