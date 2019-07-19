#include <vcpkg-tests/catch.h>
#include <vcpkg-tests/util.h>

#include <vcpkg/base/files.h>
#include <vcpkg/statusparagraph.h>

#include <iostream>
#include <memory>

#if defined(_WIN32)
#include <windows.h>
#endif

namespace vcpkg::Test
{
    std::unique_ptr<vcpkg::StatusParagraph> make_status_pgh(const char* name,
                                                            const char* depends,
                                                            const char* default_features,
                                                            const char* triplet)
    {
        using Pgh = std::unordered_map<std::string, std::string>;
        return std::make_unique<StatusParagraph>(Pgh{{"Package", name},
                                                     {"Version", "1"},
                                                     {"Architecture", triplet},
                                                     {"Multi-Arch", "same"},
                                                     {"Depends", depends},
                                                     {"Default-Features", default_features},
                                                     {"Status", "install ok installed"}});
    }

    std::unique_ptr<StatusParagraph> make_status_feature_pgh(const char* name,
                                                             const char* feature,
                                                             const char* depends,
                                                             const char* triplet)
    {
        using Pgh = std::unordered_map<std::string, std::string>;
        return std::make_unique<StatusParagraph>(Pgh{{"Package", name},
                                                     {"Version", "1"},
                                                     {"Feature", feature},
                                                     {"Architecture", triplet},
                                                     {"Multi-Arch", "same"},
                                                     {"Depends", depends},
                                                     {"Status", "install ok installed"}});
    }

    PackageSpec unsafe_pspec(std::string name, Triplet t)
    {
        auto m_ret = PackageSpec::from_name_and_triplet(name, t);
        REQUIRE(m_ret.has_value());
        return m_ret.value_or_exit(VCPKG_LINE_INFO);
    }


    #if defined(_WIN32)

    static bool system_allows_symlinks() {
        HKEY key;
        bool allow_symlinks = true;

        const auto status = RegOpenKeyExW(
            HKEY_LOCAL_MACHINE, LR"(SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock)", 0, 0, &key);

        if (status == ERROR_FILE_NOT_FOUND)
        {
            allow_symlinks = false;
            std::clog << "Symlinks are not allowed on this system\n";
        }

        if (status == ERROR_SUCCESS) RegCloseKey(key);

        return allow_symlinks;
    }

    static fs::path internal_temporary_directory() {
        wchar_t* tmp = static_cast<wchar_t*>(std::calloc(32'767, 2));

        if (!GetEnvironmentVariableW(L"TEMP", tmp, 32'767)) {
            std::cerr << "No temporary directory found.\n";
            std::abort();
        }

        fs::path result = tmp;
        std::free(tmp);

        return result / L"vcpkg-test";
    }

    #else

    constexpr static bool system_allows_symlinks() {
        return true;
    }
    static fs::path internal_temporary_directory() {
        return "/tmp/vcpkg-test";
    }

    #endif

    const bool SYMLINKS_ALLOWED = system_allows_symlinks();
    const fs::path TEMPORARY_DIRECTORY = internal_temporary_directory();
}
