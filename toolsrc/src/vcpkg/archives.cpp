#include "pch.h"

#include <vcpkg/archives.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/commands.h>

namespace vcpkg::Archives
{
    void extract_archive(const VcpkgPaths& paths, const fs::path& archive, const fs::path& to_path)
    {
        Files::Filesystem& fs = paths.get_filesystem();
        const fs::path to_path_partial = to_path.u8string() + ".partial"
#if defined(_WIN32)
                                         + "." + std::to_string(GetCurrentProcessId())
#endif
            ;

        std::error_code ec;
        fs.remove_all(to_path, ec);
        fs.remove_all(to_path_partial, ec);
        fs.create_directories(to_path_partial, ec);
        const auto ext = archive.extension();
#if defined(_WIN32)
        if (ext == ".nupkg")
        {
            static bool recursion_limiter_sevenzip_old = false;
            Checks::check_exit(VCPKG_LINE_INFO, !recursion_limiter_sevenzip_old);
            recursion_limiter_sevenzip_old = true;
            const auto nuget_exe = paths.get_tool_exe(Tools::NUGET);

            const std::string stem = archive.stem().u8string();
            // assuming format of [name].[version in the form d.d.d]
            // This assumption may not always hold
            std::smatch match;
            const bool has_match = std::regex_match(stem, match, std::regex{R"###(^(.+)\.(\d+\.\d+\.\d+)$)###"});
            Checks::check_exit(VCPKG_LINE_INFO,
                               has_match,
                               "Could not deduce nuget id and version from filename: %s",
                               archive.u8string());

            const std::string nugetid = match[1];
            const std::string version = match[2];

            const auto code_and_output = System::cmd_execute_and_capture_output(Strings::format(
                R"("%s" install %s -Version %s -OutputDirectory "%s" -Source "%s" -nocache -DirectDownload -NonInteractive -ForceEnglishOutput -PackageSaveMode nuspec)",
                nuget_exe.u8string(),
                nugetid,
                version,
                to_path_partial.u8string(),
                paths.downloads.u8string()));

            Checks::check_exit(VCPKG_LINE_INFO,
                               code_and_output.exit_code == 0,
                               "Failed to extract '%s' with message:\n%s",
                               archive.u8string(),
                               code_and_output.output);
            recursion_limiter_sevenzip_old = false;
        }
        else
        {
            static bool recursion_limiter_sevenzip = false;
            Checks::check_exit(VCPKG_LINE_INFO, !recursion_limiter_sevenzip);
            recursion_limiter_sevenzip = true;
            const auto seven_zip = paths.get_tool_exe(Tools::SEVEN_ZIP);
            const auto code_and_output = System::cmd_execute_and_capture_output(Strings::format(
                R"("%s" x "%s" -o"%s" -y)", seven_zip.u8string(), archive.u8string(), to_path_partial.u8string()));
            Checks::check_exit(VCPKG_LINE_INFO,
                               code_and_output.exit_code == 0,
                               "7zip failed while extracting '%s' with message:\n%s",
                               archive.u8string(),
                               code_and_output.output);
            recursion_limiter_sevenzip = false;
        }
#else
        if (ext == ".gz" && ext.extension() != ".tar")
        {
            const auto code = System::cmd_execute(
                Strings::format(R"(cd '%s' && tar xzf '%s')", to_path_partial.u8string(), archive.u8string()));
            Checks::check_exit(VCPKG_LINE_INFO, code == 0, "tar failed while extracting %s", archive.u8string());
        }
        else if (ext == ".zip")
        {
            const auto code = System::cmd_execute(
                Strings::format(R"(cd '%s' && unzip -qqo '%s')", to_path_partial.u8string(), archive.u8string()));
            Checks::check_exit(VCPKG_LINE_INFO, code == 0, "unzip failed while extracting %s", archive.u8string());
        }
        else
        {
            Checks::exit_with_message(VCPKG_LINE_INFO, "Unexpected archive extension: %s", ext.u8string());
        }
#endif

        fs.rename(to_path_partial, to_path, ec);

        for (int i = 0; i < 5 && ec; i++)
        {
            i++;
            using namespace std::chrono_literals;
            std::this_thread::sleep_for(i * 100ms);
            fs.rename(to_path_partial, to_path, ec);
        }

        Checks::check_exit(VCPKG_LINE_INFO,
                           !ec,
                           "Failed to do post-extract rename-in-place.\n"
                           "fs.rename(%s, %s, %s)",
                           to_path_partial.u8string(),
                           to_path.u8string(),
                           ec.message());
    }
}
