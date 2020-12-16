#pragma once

#include <vcpkg/base/expected.h>

#include <vcpkg/packagespec.h>
#include <vcpkg/textrowcol.h>

#include <map>
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>

namespace vcpkg::Parse
{
    struct ParseControlErrorInfo
    {
        std::string name;
        std::map<std::string, std::vector<std::string>> missing_fields;
        std::map<std::string, std::vector<std::string>> extra_fields;
        std::map<std::string, std::string> expected_types;
        std::map<std::string, std::vector<std::string>> mutually_exclusive_fields;
        std::vector<std::string> other_errors;
        std::string error;

        bool has_error() const
        {
            return !missing_fields.empty() || !extra_fields.empty() || !expected_types.empty() ||
                   !other_errors.empty() || !error.empty();
        }
    };

    template<class P>
    using ParseExpected = vcpkg::ExpectedT<std::unique_ptr<P>, std::unique_ptr<ParseControlErrorInfo>>;

    using Paragraph = std::unordered_map<std::string, std::pair<std::string, TextRowCol>>;

    struct ParagraphParser
    {
        ParagraphParser(Paragraph&& fields) : fields(std::move(fields)) { }

        std::string required_field(const std::string& fieldname);
        void required_field(const std::string& fieldname, std::string& out);
        void required_field(const std::string& fieldname, std::pair<std::string&, TextRowCol&> out);

        std::string optional_field(const std::string& fieldname);
        void optional_field(const std::string& fieldname, std::pair<std::string&, TextRowCol&> out);

        void add_type_error(const std::string& fieldname, const char* type) { expected_types[fieldname] = type; }

        std::unique_ptr<ParseControlErrorInfo> error_info(const std::string& name) const;

    private:
        Paragraph&& fields;
        std::vector<std::string> missing_fields;
        std::map<std::string, std::string> expected_types;
    };

    ExpectedS<std::vector<std::string>> parse_default_features_list(const std::string& str,
                                                                    StringView origin = "<unknown>",
                                                                    TextRowCol textrowcol = {});
    ExpectedS<std::vector<ParsedQualifiedSpecifier>> parse_qualified_specifier_list(const std::string& str,
                                                                                    StringView origin = "<unknown>",
                                                                                    TextRowCol textrowcol = {});
    ExpectedS<std::vector<Dependency>> parse_dependencies_list(const std::string& str,
                                                               StringView origin = "<unknown>",
                                                               TextRowCol textrowcol = {});
}
