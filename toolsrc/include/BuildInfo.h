#pragma once

#include <unordered_map>
#include "Paragraphs.h"
#include <regex>

namespace fs = std::tr2::sys;

namespace vcpkg
{
    enum class LinkageType
    {
        DYNAMIC,
        STATIC,
        UNKNOWN
    };

    LinkageType linkage_type_value_of(const std::string& as_string);

    std::string to_string(const LinkageType& build_info);

    enum class ConfigurationType
    {
        DEBUG = 1,
        RELEASE = 2
    };

    std::string to_string(const ConfigurationType& conf);

    struct BuildType
    {
        static BuildType value_of(const ConfigurationType& config, const LinkageType& linkage);

        static const BuildType DEBUG_STATIC;
        static const BuildType DEBUG_DYNAMIC;
        static const BuildType RELEASE_STATIC;
        static const BuildType RELEASE_DYNAMIC;

        static const std::vector<BuildType>& values()
        {
            static const std::vector<BuildType> v = {DEBUG_STATIC, DEBUG_DYNAMIC, RELEASE_STATIC, RELEASE_DYNAMIC};
            return v;
        }

        BuildType() = delete;

        const ConfigurationType& config() const;
        const LinkageType& linkage() const;
        const std::regex& crt_regex() const;
        const std::string& toString() const;

    private:
        BuildType(const ConfigurationType& config, const LinkageType& linkage, const std::string& crt_regex_as_string)
            : m_config(config), m_linkage(linkage), m_crt_regex_as_string(crt_regex_as_string)
        {
        }

        ConfigurationType m_config;
        LinkageType m_linkage;
        std::string m_crt_regex_as_string;
    };

    bool operator ==(const BuildType& lhs, const BuildType& rhs);

    bool operator !=(const BuildType& lhs, const BuildType& rhs);

    struct OutdatedDynamicCrt
    {
        // Old CPP
        static const OutdatedDynamicCrt MSVCP100_DLL;
        static const OutdatedDynamicCrt MSVCP100D_DLL;
        static const OutdatedDynamicCrt MSVCP110_DLL;
        static const OutdatedDynamicCrt MSVCP110_WIN_DLL;
        static const OutdatedDynamicCrt MSVCP120_DLL;
        static const OutdatedDynamicCrt MSVCP120_CLR0400_DLL;
        static const OutdatedDynamicCrt MSVCP60_DLL;
        static const OutdatedDynamicCrt MSVCP_WIN_DLL;

        // Old C
        static const OutdatedDynamicCrt MSVCR100_DLL;
        static const OutdatedDynamicCrt MSVCR100D_DLL;
        static const OutdatedDynamicCrt MSVCR100_CLR0400_DLL;
        static const OutdatedDynamicCrt MSVCR110_DLL;
        static const OutdatedDynamicCrt MSVCR120_DLL;
        static const OutdatedDynamicCrt MSVCR120_CLR0400_DLL;
        static const OutdatedDynamicCrt MSVCRT_DLL;
        static const OutdatedDynamicCrt MSVCRT20_DLL;
        static const OutdatedDynamicCrt MSVCRT40_DLL;

        static const std::vector<OutdatedDynamicCrt>& values()
        {
            static const std::vector<OutdatedDynamicCrt> v = {
                MSVCP100_DLL, MSVCP100D_DLL,
                MSVCP110_DLL,MSVCP110_WIN_DLL,
                MSVCP120_DLL, MSVCP120_CLR0400_DLL,
                MSVCP60_DLL,
                MSVCP_WIN_DLL,

                MSVCR100_DLL, MSVCR100D_DLL, MSVCR100_CLR0400_DLL,
                MSVCR110_DLL,
                MSVCR120_DLL, MSVCR120_CLR0400_DLL,
                MSVCRT_DLL, MSVCRT20_DLL,MSVCRT40_DLL
            };
            return v;
        }

        OutdatedDynamicCrt() = delete;

        const std::regex& crt_regex() const;
        const std::string& toString() const;

    private:
        explicit OutdatedDynamicCrt(const std::string& dll_name, const std::string& crt_regex_as_string)
            : m_dll_name(dll_name), m_crt_regex_as_string(crt_regex_as_string)
        {
        }

        std::string m_dll_name;
        std::string m_crt_regex_as_string;
    };

    struct BuildInfo
    {
        static BuildInfo create(const std::unordered_map<std::string, std::string>& pgh);

        std::string crt_linkage;
        std::string library_linkage;
    };

    BuildInfo read_build_info(const fs::path& filepath);
}
