#include "vcpkg_Checks.h"
#include "vcpkglib_helpers.h"
#include <unordered_map>

namespace vcpkg {namespace details
{
    void optional_field(const std::unordered_map<std::string, std::string>& fields, std::string& out, const std::string& fieldname)
    {
        auto it = fields.find(fieldname);
        if (it == fields.end())
        {
            out.clear();
        }

        else
        {
            out = it->second;
        }
    };

    void required_field(const std::unordered_map<std::string, std::string>& fields, std::string& out, const std::string& fieldname)
    {
        auto it = fields.find(fieldname);
        vcpkg::Checks::check_throw(it != fields.end(), "Required field not present: %s", fieldname);
        out = it->second;
    };

    void parse_depends(const std::string& depends_string, std::vector<std::string>& out)
    {
        size_t cur = 0;
        do
        {
            auto pos = depends_string.find(',', cur);
            if (pos == std::string::npos)
            {
                out.push_back(depends_string.substr(cur));
                return;
            }
            out.push_back(depends_string.substr(cur, pos - cur));

            // skip comma and space
            ++pos;
            if (depends_string[pos] == ' ')
                ++pos;

            cur = pos;
        }
        while (cur != std::string::npos);
    }
}}
