#include "pch.h"

#include "vcpkg_Checks.h"
#include "vcpkg_Maps.h"
#include "vcpkg_Parse.h"

namespace vcpkg::Parse
{
    static Optional<std::string> remove_field(std::unordered_map<std::string, std::string>* fields,
                                              const std::string& fieldname)
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
        if (auto field = maybe_field.get())
            out = std::move(*field);
        else
            missing_fields.push_back(fieldname);
    }
    std::string ParagraphParser::optional_field(const std::string& fieldname)
    {
        return remove_field(&fields, fieldname).value_or("");
    }
    std::unique_ptr<ParseControlErrorInfo> ParagraphParser::error_info(const std::string& name) const
    {
        if (!fields.empty() || !missing_fields.empty())
        {
            auto err = std::make_unique<ParseControlErrorInfo>();
            err->name = name;
            err->extra_fields = Maps::extract_keys(fields);
            err->missing_fields = std::move(missing_fields);
            return err;
        }
        return nullptr;
    }
}
