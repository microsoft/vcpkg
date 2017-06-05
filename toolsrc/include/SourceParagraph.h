#pragma once

#include "vcpkg_expected.h"
#include <unordered_map>
#include <vector>

namespace vcpkg
{
    struct Triplet;

    struct Dependency
    {
        std::string name;
        std::string qualifier;
    };

    const std::string& to_string(const Dependency& dep);

    struct ParseControlErrorInfo
    {
        std::string name;
        std::string remaining_fields_as_string;
        std::string valid_fields_as_string;
        std::error_code error;
    };

    /// <summary>
    /// Port metadata (CONTROL file)
    /// </summary>
    struct SourceParagraph
    {
        static ExpectedT<SourceParagraph, ParseControlErrorInfo> parse_control_file(
            std::unordered_map<std::string, std::string> fields);

        SourceParagraph();

        std::string name;
        std::string version;
        std::string description;
        std::string maintainer;
        std::vector<Dependency> depends;
    };

    void print_error_message(const ParseControlErrorInfo& info);
    void print_error_message(std::vector<ParseControlErrorInfo> error_info_list);

    std::vector<std::string> filter_dependencies(const std::vector<Dependency>& deps, const Triplet& t);

    std::vector<Dependency> expand_qualified_dependencies(const std::vector<std::string>& depends);
    std::vector<std::string> parse_depends(const std::string& depends_string);
}
