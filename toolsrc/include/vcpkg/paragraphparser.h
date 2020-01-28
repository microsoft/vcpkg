#pragma once

#include <vcpkg/base/expected.h>

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

    using RawParagraph = std::unordered_map<std::string, std::string>;

    struct ParagraphParser
    {
        ParagraphParser(RawParagraph&& fields) : fields(std::move(fields)) {}

        void required_field(const std::string& fieldname, std::string& out);
        std::string optional_field(const std::string& fieldname) const;
        std::unique_ptr<ParseControlErrorInfo> error_info(const std::string& name) const;

    private:
        RawParagraph&& fields;
        std::vector<std::string> missing_fields;
    };

    std::vector<std::string> parse_comma_list(const std::string& str);
}
