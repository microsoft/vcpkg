#include  "BuildInfo.h"
#include "vcpkg_Checks.h"
#include "vcpkglib_helpers.h"

namespace vcpkg
{
    //
    namespace BuildInfoRequiredField
    {
        static const std::string CRT_LINKAGE = "CRTLinkage";
        static const std::string LIBRARY_LINKAGE = "LibraryLinkage";
    }

    BuildInfo BuildInfo::create(const std::unordered_map<std::string, std::string>& pgh)
    {
        BuildInfo build_info;
        build_info.crt_linkage = details::required_field(pgh, BuildInfoRequiredField::CRT_LINKAGE);
        build_info.library_linkage = details::required_field(pgh, BuildInfoRequiredField::LIBRARY_LINKAGE);

        return build_info;
    }

    LinkageType linkage_type_value_of(const std::string& as_string)

    {
        if (as_string == "dynamic")
        {
            return LinkageType::DYNAMIC;
        }

        if (as_string == "static")
        {
            return LinkageType::STATIC;
        }

        return LinkageType::UNKNOWN;
    }

    BuildInfo read_build_info(const fs::path& filepath)
    {
        const std::vector<std::unordered_map<std::string, std::string>> pghs = Paragraphs::get_paragraphs(filepath);
        Checks::check_throw(pghs.size() == 1, "Invalid BUILD_INFO file for package");

        return BuildInfo::create(pghs[0]);
    }
}
