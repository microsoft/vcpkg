#include <catch2/catch.hpp>
#include <vcpkg-test/util.h>

#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/util.h>
#include <vcpkg/statusparagraph.h>

// used to get the implementation specific compiler flags (i.e., __cpp_lib_filesystem)
#include <ciso646>

#include <iostream>
#include <memory>

#if defined(_WIN32)
#include <windows.h>
#endif

#define FILESYSTEM_SYMLINK_STD 0
#define FILESYSTEM_SYMLINK_UNIX 1
#define FILESYSTEM_SYMLINK_NONE 2

#if defined(__cpp_lib_filesystem)

#define FILESYSTEM_SYMLINK FILESYSTEM_SYMLINK_STD
#include <filesystem> // required for filesystem::create_{directory_}symlink

#elif !defined(_MSC_VER)

#define FILESYSTEM_SYMLINK FILESYSTEM_SYMLINK_UNIX
#include <unistd.h>

#else

#define FILESYSTEM_SYMLINK FILESYSTEM_SYMLINK_NONE

#endif

namespace vcpkg::Test
{
    std::unique_ptr<SourceControlFile> make_control_file(
        const char* name,
        const char* depends,
        const std::vector<std::pair<const char*, const char*>>& features,
        const std::vector<const char*>& default_features)
    {
        using Pgh = std::unordered_map<std::string, std::string>;
        std::vector<Pgh> scf_pghs;
        scf_pghs.push_back(Pgh{{"Source", name},
                               {"Version", "0"},
                               {"Build-Depends", depends},
                               {"Default-Features", Strings::join(", ", default_features)}});
        for (auto&& feature : features)
        {
            scf_pghs.push_back(Pgh{
                {"Feature", feature.first},
                {"Description", "feature"},
                {"Build-Depends", feature.second},
            });
        }
        auto m_pgh = test_parse_control_file(std::move(scf_pghs));
        REQUIRE(m_pgh.has_value());
        return std::move(*m_pgh.get());
    }

    std::unique_ptr<vcpkg::StatusParagraph> make_status_pgh(const char* name,
                                                            const char* depends,
                                                            const char* default_features,
                                                            const char* triplet)
    {
        return std::make_unique<StatusParagraph>(Parse::Paragraph{{"Package", {name, {}}},
                                                                  {"Version", {"1", {}}},
                                                                  {"Architecture", {triplet, {}}},
                                                                  {"Multi-Arch", {"same", {}}},
                                                                  {"Depends", {depends, {}}},
                                                                  {"Default-Features", {default_features, {}}},
                                                                  {"Status", {"install ok installed", {}}}});
    }

    std::unique_ptr<StatusParagraph> make_status_feature_pgh(const char* name,
                                                             const char* feature,
                                                             const char* depends,
                                                             const char* triplet)
    {
        return std::make_unique<StatusParagraph>(Parse::Paragraph{{"Package", {name, {}}},
                                                                  {"Feature", {feature, {}}},
                                                                  {"Architecture", {triplet, {}}},
                                                                  {"Multi-Arch", {"same", {}}},
                                                                  {"Depends", {depends, {}}},
                                                                  {"Status", {"install ok installed", {}}}});
    }

    PackageSpec PackageSpecMap::emplace(const char* name,
                                        const char* depends,
                                        const std::vector<std::pair<const char*, const char*>>& features,
                                        const std::vector<const char*>& default_features)
    {
        auto scfl = SourceControlFileLocation{make_control_file(name, depends, features, default_features), ""};
        return emplace(std::move(scfl));
    }

    PackageSpec PackageSpecMap::emplace(vcpkg::SourceControlFileLocation&& scfl)
    {
        map.emplace(scfl.source_control_file->core_paragraph->name, std::move(scfl));
        return {scfl.source_control_file->core_paragraph->name, triplet};
    }

    static AllowSymlinks internal_can_create_symlinks() noexcept
    {
#if FILESYSTEM_SYMLINK == FILESYSTEM_SYMLINK_NONE
        return AllowSymlinks::No;
#elif FILESYSTEM_SYMLINK == FILESYSTEM_SYMLINK_UNIX
        return AllowSymlinks::Yes;
#elif !defined(_WIN32) // FILESYSTEM_SYMLINK == FILESYSTEM_SYMLINK_STD
        return AllowSymlinks::Yes;
#else
        constexpr static const wchar_t regkey[] =
            LR"(SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock)";
        constexpr static const wchar_t regkey_member[] = LR"(AllowDevelopmentWithoutDevLicense)";

        DWORD data;
        DWORD dataSize = sizeof(data);
        const auto status = RegGetValueW(
            HKEY_LOCAL_MACHINE, regkey, regkey_member, RRF_RT_DWORD, nullptr, &data, &dataSize);

        if (status == ERROR_SUCCESS && data == 1) {
            return AllowSymlinks::Yes;
        } else {
            std::clog << "Symlinks are not allowed on this system\n";
            return AllowSymlinks::No;
        }
#endif
    }
    const static AllowSymlinks CAN_CREATE_SYMLINKS = internal_can_create_symlinks();

    AllowSymlinks can_create_symlinks() noexcept { return CAN_CREATE_SYMLINKS; }

    static fs::path internal_base_temporary_directory()
    {
#if defined(_WIN32)
        wchar_t* tmp = static_cast<wchar_t*>(std::calloc(32'767, 2));

        if (!GetEnvironmentVariableW(L"TEMP", tmp, 32'767))
        {
            std::cerr << "No temporary directory found.\n";
            std::abort();
        }

        fs::path result = tmp;
        std::free(tmp);

        return result / L"vcpkg-test";
#else
        return "/tmp/vcpkg-test";
#endif
    }

    const static fs::path BASE_TEMPORARY_DIRECTORY = internal_base_temporary_directory();

    const fs::path& base_temporary_directory() noexcept { return BASE_TEMPORARY_DIRECTORY; }

#if FILESYSTEM_SYMLINK == FILESYSTEM_SYMLINK_NONE
    constexpr char no_filesystem_message[] =
        "<filesystem> doesn't exist; on windows, we don't attempt to use the win32 calls to create symlinks";
#endif

    void create_symlink(const fs::path& target, const fs::path& file, std::error_code& ec)
    {
#if FILESYSTEM_SYMLINK == FILESYSTEM_SYMLINK_STD
        if (can_create_symlinks())
        {
            std::filesystem::path targetp = target.native();
            std::filesystem::path filep = file.native();

            std::filesystem::create_symlink(targetp, filep, ec);
        }
        else
        {
            vcpkg::Checks::exit_with_message(VCPKG_LINE_INFO, "Symlinks are not allowed on this system");
        }
#elif FILESYSTEM_SYMLINK == FILESYSTEM_SYMLINK_UNIX
        if (symlink(target.c_str(), file.c_str()) != 0)
        {
            ec.assign(errno, std::system_category());
        }
#else
        Util::unused(target, file, ec);
        vcpkg::Checks::exit_with_message(VCPKG_LINE_INFO, no_filesystem_message);
#endif
    }

    void create_directory_symlink(const fs::path& target, const fs::path& file, std::error_code& ec)
    {
#if FILESYSTEM_SYMLINK == FILESYSTEM_SYMLINK_STD
        if (can_create_symlinks())
        {
            std::filesystem::path targetp = target.native();
            std::filesystem::path filep = file.native();

            std::filesystem::create_directory_symlink(targetp, filep, ec);
        }
        else
        {
            vcpkg::Checks::exit_with_message(VCPKG_LINE_INFO, "Symlinks are not allowed on this system");
        }
#elif FILESYSTEM_SYMLINK == FILESYSTEM_SYMLINK_UNIX
        ::vcpkg::Test::create_symlink(target, file, ec);
#else
        Util::unused(target, file, ec);
        vcpkg::Checks::exit_with_message(VCPKG_LINE_INFO, no_filesystem_message);
#endif
    }
}
