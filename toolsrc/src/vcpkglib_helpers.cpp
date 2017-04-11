#include "pch.h"
#include "vcpkg_Checks.h"
#include "vcpkglib_helpers.h"

namespace vcpkg::details
{
    std::string optional_field(const std::unordered_map<std::string, std::string>& fields, const std::string& fieldname)
    {
        auto it = fields.find(fieldname);
        if (it == fields.end())
        {
            return std::string();
        }

        return it->second;
    }

    std::string remove_optional_field(std::unordered_map<std::string, std::string>* fields, const std::string& fieldname)
    {
        auto it = fields->find(fieldname);
        if (it == fields->end())
        {
            return std::string();
        }

        const std::string value = std::move(it->second);
        fields->erase(it);
        return value;
    }

    std::string required_field(const std::unordered_map<std::string, std::string>& fields, const std::string& fieldname)
    {
        auto it = fields.find(fieldname);
        Checks::check_exit(VCPKG_LINE_INFO, it != fields.end(), "Required field not present: %s", fieldname);
        return it->second;
    }

    std::string remove_required_field(std::unordered_map<std::string, std::string>* fields, const std::string& fieldname)
    {
        auto it = fields->find(fieldname);
        Checks::check_exit(VCPKG_LINE_INFO, it != fields->end(), "Required field not present: %s", fieldname);

        const std::string value = std::move(it->second);
        fields->erase(it);
        return value;
    }

    std::string shorten_description(const std::string& desc)
    {
        auto simple_desc = std::regex_replace(desc, std::regex("\\s+"), " ");
        return simple_desc.size() <= 52
            ? simple_desc
            : simple_desc.substr(0, 49) + "...";
    }
}
