#include "pch.h"

#include <vcpkg/parse.h>

#include <vcpkg/base/util.h>
#include <vcpkg/base/system.print.h>

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

	static bool is_whitespace(char c)
	{
		return c == ' ' || c == '\t' || c == '\n' || c == '\r';
	}

    std::vector<std::string> parse_comma_list(const std::string& str)
    {
        if (str.empty())
        {
            return {};
        }

        std::vector<std::string> out;

		auto iter = str.cbegin();

		do {
			// Trim leading whitespace of each element
			while (iter != str.cend() && is_whitespace(*iter))
			{
				++iter;
			}

			// Allow commas inside of [].
			bool bracket_nesting = false;

			auto element_begin = iter;
			auto element_end = iter;
			while (iter != str.cend() && (*iter != ',' || bracket_nesting))
			{
				char value = *iter;

				// do not support nested []
				if (value == '[')
				{
					bracket_nesting = true;
				}
				else if (value == ']')
				{
					bracket_nesting = false;
				}

				++iter;

				// Trim ending whitespace
				if (!is_whitespace(value))
				{
					// Update element_end after iter is incremented so it will be one past.
					element_end = iter;
				}
			}

			if (element_begin == element_end)
			{
				System::print2(	System::Color::warning, 
					"Warning: empty element in list\n"
					">    '", str, "'\n"
					">     ", std::string(static_cast<int>(element_begin - str.cbegin()), ' '), "^\n"
				);
			}
			else
			{
				out.push_back({ element_begin, element_end });
			}

			if (iter != str.cend())
			{
				//Not at the end, must be at a comma that needs to be stepped over
				++iter;

				if (iter == str.end())
				{
					System::print2(System::Color::warning,
						"Warning: empty element in list\n"
						">    '", str, "'\n"
						">     ", std::string(str.length(), ' '), "^\n"
					);
				}
			}

		} while (iter != str.cend());

        return out;
    }
}
