#include <vcpkg/base/checks.h>

#include <vcpkg/postbuildlint.buildtype.h>

using vcpkg::Build::ConfigurationType;

namespace vcpkg::PostBuildLint
{
    BuildType BuildType::value_of(const ConfigurationType& config, const Build::LinkageType& linkage)
    {
        if (config == ConfigurationType::DEBUG && linkage == Build::LinkageType::STATIC)
        {
            return BuildTypeC::DEBUG_STATIC;
        }

        if (config == ConfigurationType::DEBUG && linkage == Build::LinkageType::DYNAMIC)
        {
            return BuildTypeC::DEBUG_DYNAMIC;
        }

        if (config == ConfigurationType::RELEASE && linkage == Build::LinkageType::STATIC)
        {
            return BuildTypeC::RELEASE_STATIC;
        }

        if (config == ConfigurationType::RELEASE && linkage == Build::LinkageType::DYNAMIC)
        {
            return BuildTypeC::RELEASE_DYNAMIC;
        }

        Checks::unreachable(VCPKG_LINE_INFO);
    }

    const ConfigurationType& BuildType::config() const { return this->m_config; }

    const Build::LinkageType& BuildType::linkage() const { return this->m_linkage; }

    const std::regex& BuildType::crt_regex() const
    {
        static const std::regex REGEX_DEBUG_STATIC(R"(/DEFAULTLIB:LIBCMTD)", std::regex_constants::icase);
        static const std::regex REGEX_DEBUG_DYNAMIC(R"(/DEFAULTLIB:MSVCRTD)", std::regex_constants::icase);
        static const std::regex REGEX_RELEASE_STATIC(R"(/DEFAULTLIB:LIBCMT[^D])", std::regex_constants::icase);
        static const std::regex REGEX_RELEASE_DYNAMIC(R"(/DEFAULTLIB:MSVCRT[^D])", std::regex_constants::icase);

        switch (backing_enum)
        {
            case BuildTypeC::DEBUG_STATIC: return REGEX_DEBUG_STATIC;
            case BuildTypeC::DEBUG_DYNAMIC: return REGEX_DEBUG_DYNAMIC;
            case BuildTypeC::RELEASE_STATIC: return REGEX_RELEASE_STATIC;
            case BuildTypeC::RELEASE_DYNAMIC: return REGEX_RELEASE_DYNAMIC;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    const std::string& BuildType::to_string() const
    {
        static const std::string NAME_DEBUG_STATIC("Debug,Static");
        static const std::string NAME_DEBUG_DYNAMIC("Debug,Dynamic");
        static const std::string NAME_RELEASE_STATIC("Release,Static");
        static const std::string NAME_RELEASE_DYNAMIC("Release,Dynamic");

        switch (backing_enum)
        {
            case BuildTypeC::DEBUG_STATIC: return NAME_DEBUG_STATIC;
            case BuildTypeC::DEBUG_DYNAMIC: return NAME_DEBUG_DYNAMIC;
            case BuildTypeC::RELEASE_STATIC: return NAME_RELEASE_STATIC;
            case BuildTypeC::RELEASE_DYNAMIC: return NAME_RELEASE_DYNAMIC;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }
}
