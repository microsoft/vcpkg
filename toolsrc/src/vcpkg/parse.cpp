#include "pch.h"

#include <vcpkg/parse.h>

#include <vcpkg/base/util.h>

namespace vcpkg::Parse
{
    static Optional<std::string> remove_field(RawParagraph* fields, const std::string& fieldname)
    {
        auto it = fields->find(fieldname);
        if (it == fields->end())
        {
            return nullopt;
        }

        const std::string value = std::move(it->second);
        fields->erase(it);
        return value;
    }

    void ParagraphParser::required_field(const std::string& fieldname, std::string& out)
    {
        auto maybe_field = remove_field(&fields, fieldname);
        if (const auto field = maybe_field.get())
            out = std::move(*field);
        else
            missing_fields.push_back(fieldname);
    }
    std::string ParagraphParser::optional_field(const std::string& fieldname) const
    {
        return remove_field(&fields, fieldname).value_or("");
    }
    std::unique_ptr<ParseControlErrorInfo> ParagraphParser::error_info(const std::string& name) const
    {
        if (!fields.empty() || !missing_fields.empty())
        {
            auto err = std::make_unique<ParseControlErrorInfo>();
            err->name = name;
            err->extra_fields = Util::extract_keys(fields);
            err->missing_fields = std::move(missing_fields);
            return err;
        }
        return nullptr;
    }

    std::vector<std::string> parse_comma_list(const std::string& str)
    {
        if (str.empty())
        {
            return {};
        }

        std::vector<std::string> out;

        size_t cur = 0;
        do
        {
            auto pos = str.find(',', cur);
            if (pos == std::string::npos)
            {
                out.push_back(str.substr(cur));
                break;
            }
            out.push_back(str.substr(cur, pos - cur));

            // skip comma and space
            ++pos;
            if (str[pos] == ' ')
            {
                ++pos;
            }

            cur = pos;
        } while (cur != std::string::npos);

        return out;
    }
}
