#pragma once

#include "Span.h"
#include "vcpkg_System.h"
#include "vcpkg_expected.h"

#include <string>
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
        std::error_code error;
    };

    /// <summary>
    /// Port metadata (CONTROL file)
    /// </summary>
    struct SourceParagraph
    {
        static ExpectedT<SourceParagraph, ParseControlErrorInfo> parse_control_file(
            std::unordered_map<std::string, std::string> fields);

        SourceParagraph() = default;

        std::string name;
        std::string version;
        std::string description;
        std::string maintainer;
        std::vector<std::string> supports;
        std::vector<Dependency> depends;
    };

    void print_error_message(span<const ParseControlErrorInfo> error_info_list);
    inline void print_error_message(const ParseControlErrorInfo& error_info_list)
    {
        return print_error_message({&error_info_list, 1});
    }

    std::vector<std::string> filter_dependencies(const std::vector<Dependency>& deps, const Triplet& t);

    std::vector<Dependency> expand_qualified_dependencies(const std::vector<std::string>& depends);
    std::vector<std::string> parse_comma_list(const std::string& str);

    struct Supports
    {
        static ExpectedT<Supports, std::vector<std::string>> parse(const std::vector<std::string>& strs);

        using Architecture = System::CPUArchitecture;

        enum class Platform
        {
            WINDOWS,
            UWP,
        };
        enum class Linkage
        {
            DYNAMIC,
            STATIC,
        };
        enum class ToolsetVersion
        {
            V140,
            V141,
        };

        bool is_supported(Architecture arch, Platform plat, Linkage crt, ToolsetVersion tools);

    private:
        std::vector<Architecture> architectures;
        std::vector<Platform> platforms;
        std::vector<Linkage> crt_linkages;
        std::vector<ToolsetVersion> toolsets;
    };
}
