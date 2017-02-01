#pragma once
#include <vector>
#include <regex>

namespace vcpkg::PostBuildLint
{
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

        std::regex crt_regex() const;
        const std::string& toString() const;

    private:
        explicit OutdatedDynamicCrt(const std::string& dll_name, const std::string& crt_regex_as_string)
            : m_dll_name(dll_name), m_crt_regex_as_string(crt_regex_as_string) { }

        std::string m_dll_name;
        std::string m_crt_regex_as_string;
    };
}
