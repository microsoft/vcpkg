#include "vcpkg_Checks.h"
#include "vcpkglib_helpers.h"
#include <unordered_map>

namespace vcpkg {namespace details
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
        Checks::check_exit(it != fields.end(), "Required field not present: %s", fieldname);
        return it->second;
    }

    std::string remove_required_field(std::unordered_map<std::string, std::string>* fields, const std::string& fieldname)
    {
        auto it = fields->find(fieldname);
        Checks::check_exit(it != fields->end(), "Required field not present: %s", fieldname);

        const std::string value = std::move(it->second);
        fields->erase(it);
        return value;
    }

    std::vector<std::string> parse_depends(const std::string& depends_string)
    {
        if (depends_string.empty())
        {
            return {};
        }

        std::vector<std::string> out;

        size_t cur = 0;
        do
        {
            auto pos = depends_string.find(',', cur);
            if (pos == std::string::npos)
            {
                out.push_back(depends_string.substr(cur));
                break;
            }
            out.push_back(depends_string.substr(cur, pos - cur));

            // skip comma and space
            ++pos;
            if (depends_string[pos] == ' ')
            {
                ++pos;
            }

            cur = pos;
        }
        while (cur != std::string::npos);

        return out;
    }
}}
