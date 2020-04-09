#pragma once

#include <vcpkg/base/expected.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/textrowcol.h>

#include <memory>
#include <string>
#include <unordered_map>
#include <vector>

namespace vcpkg::Parse
{
    struct ParseControlErrorInfo
    {
        std::string name;
        std::vector<std::string> missing_fields;
        std::vector<std::string> extra_fields;
        std::string error;
    };

    template<class P>
    using ParseExpected = vcpkg::ExpectedT<std::unique_ptr<P>, std::unique_ptr<ParseControlErrorInfo>>;

    using Paragraph = std::unordered_map<std::string, std::pair<std::string, TextRowCol>>;

    struct ParagraphParser
    {
        ParagraphParser(Paragraph&& fields) : fields(std::move(fields)) {}

        void required_field(const std::string& fieldname, std::string& out);
        std::string optional_field(const std::string& fieldname);
        void required_field(const std::string& fieldname, std::pair<std::string&, TextRowCol&> out);
        void optional_field(const std::string& fieldname, std::pair<std::string&, TextRowCol&> out);
        std::unique_ptr<ParseControlErrorInfo> error_info(const std::string& name) const;

    private:
        Paragraph&& fields;
        std::vector<std::string> missing_fields;
    };

    ExpectedS<std::vector<std::string>> parse_default_features_list(const std::string& str,
                                                                    CStringView origin = "<unknown>",
                                                                    TextRowCol textrowcol = {});
    ExpectedS<std::vector<ParsedQualifiedSpecifier>> parse_qualified_specifier_list(const std::string& str,
                                                                                    CStringView origin = "<unknown>",
                                                                                    TextRowCol textrowcol = {});
    ExpectedS<std::vector<Dependency>> parse_dependencies_list(const std::string& str,
                                                               CStringView origin = "<unknown>",
                                                               TextRowCol textrowcol = {});
}
