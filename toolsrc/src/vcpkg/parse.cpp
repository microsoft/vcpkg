#include "pch.h"

#include <utility>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>
#include <vcpkg/paragraphparser.h>
#include <vcpkg/parse.h>

using namespace vcpkg;

namespace vcpkg::Parse
{
    std::string ParseError::format() const
    {
        return Strings::concat("Error: ",
                               origin,
                               ":",
                               row,
                               ":",
                               column,
                               ": ",
                               message,
                               "\n"
                               "   on expression: \"",
                               line,
                               "\"\n",
                               "                   ",
                               std::string(column - 1, ' '),
                               "^\n");
    }

    void ParserBase::add_error(std::string message, const ParserBase::SourceLoc& loc)
    {
        // avoid cascading errors by only saving the first
        if (!m_err)
        {
            // find beginning of line
            auto linestart = loc.it;
            while (linestart != m_text.c_str())
            {
                if (linestart[-1] == '\n') break;
                --linestart;
            }

            // find end of line
            auto lineend = loc.it;
            while (*lineend != '\n' && *lineend != '\r' && *lineend != '\0')
                ++lineend;
            m_err.reset(
                new ParseError(m_origin.c_str(), loc.row, loc.column, {linestart, lineend}, std::move(message)));
        }

        // Avoid error loops by skipping to the end
        skip_to_eof();
    }

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

        auto iter = str.cbegin();

        do
        {
            // Trim leading whitespace of each element
            while (iter != str.cend() && ParserBase::is_whitespace(*iter))
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
                    if (bracket_nesting)
                    {
                        Checks::exit_with_message(VCPKG_LINE_INFO,
                                                  "Lists do not support nested brackets, Did you forget a ']'?\n"
                                                  ">    '%s'\n"
                                                  ">     %s^\n",
                                                  str,
                                                  std::string(static_cast<int>(iter - str.cbegin()), ' '));
                    }
                    bracket_nesting = true;
                }
                else if (value == ']')
                {
                    if (!bracket_nesting)
                    {
                        Checks::exit_with_message(VCPKG_LINE_INFO,
                                                  "Found unmatched ']'.  Did you forget a '['?\n"
                                                  ">    '%s'\n"
                                                  ">     %s^\n",
                                                  str,
                                                  std::string(static_cast<int>(iter - str.cbegin()), ' '));
                    }
                    bracket_nesting = false;
                }

                ++iter;

                // Trim ending whitespace
                if (!ParserBase::is_whitespace(value))
                {
                    // Update element_end after iter is incremented so it will be one past.
                    element_end = iter;
                }
            }

            if (element_begin == element_end)
            {
                Checks::exit_with_message(VCPKG_LINE_INFO,
                                          "Empty element in list\n"
                                          ">    '%s'\n"
                                          ">     %s^\n",
                                          str,
                                          std::string(static_cast<int>(element_begin - str.cbegin()), ' '));
            }
            out.push_back({element_begin, element_end});

            if (iter != str.cend())
            {
                Checks::check_exit(VCPKG_LINE_INFO, *iter == ',', "Internal parsing error - expected comma");

                // Not at the end, must be at a comma that needs to be stepped over
                ++iter;

                if (iter == str.end())
                {
                    Checks::exit_with_message(VCPKG_LINE_INFO,
                                              "Empty element in list\n"
                                              ">    '%s'\n"
                                              ">     %s^\n",
                                              str,
                                              std::string(str.length(), ' '));
                }
            }

        } while (iter != str.cend());

        return out;
    }
}
