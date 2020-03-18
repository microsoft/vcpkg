#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/binarycaching.h>
#include <vcpkg/build.h>
#include <vcpkg/dependencies.h>

using namespace vcpkg;

namespace
{
    static System::ExitCodeAndOutput decompress_archive(const VcpkgPaths& paths,
                                                        const PackageSpec& spec,
                                                        const fs::path& archive_path)
    {
        auto& fs = paths.get_filesystem();

        auto pkg_path = paths.package_dir(spec);
        fs.remove_all(pkg_path, VCPKG_LINE_INFO);
        std::error_code ec;
        fs.create_directories(pkg_path, ec);
        auto files = fs.get_files_non_recursive(pkg_path);
        Checks::check_exit(VCPKG_LINE_INFO, files.empty(), "unable to clear path: %s", pkg_path.u8string());

#if defined(_WIN32)
        auto&& seven_zip_exe = paths.get_tool_exe(Tools::SEVEN_ZIP);
        auto cmd = Strings::format(
            R"("%s" x "%s" -o"%s" -y)", seven_zip_exe.u8string(), archive_path.u8string(), pkg_path.u8string());
#else
        auto cmd = Strings::format(R"(unzip -qq "%s" "-d%s")", archive_path.u8string(), pkg_path.u8string());
#endif
        return System::cmd_execute_and_capture_output(cmd, System::get_clean_environment());
    }

    // Compress the source directory into the destination file.
    static void compress_directory(const VcpkgPaths& paths, const fs::path& source, const fs::path& destination)
    {
        auto& fs = paths.get_filesystem();

        std::error_code ec;

        fs.remove(destination, ec);
        Checks::check_exit(
            VCPKG_LINE_INFO, !fs.exists(destination), "Could not remove file: %s", destination.u8string());
#if defined(_WIN32)
        auto&& seven_zip_exe = paths.get_tool_exe(Tools::SEVEN_ZIP);

        System::cmd_execute_and_capture_output(
            Strings::format(
                R"("%s" a "%s" "%s\*")", seven_zip_exe.u8string(), destination.u8string(), source.u8string()),
            System::get_clean_environment());
#else
        System::cmd_execute_clean(
            Strings::format(R"(cd '%s' && zip --quiet -r '%s' *)", source.u8string(), destination.u8string()));
#endif
    }

    struct ArchivesBinaryProvider : IBinaryProvider
    {
        ~ArchivesBinaryProvider() = default;
        void prefetch() override {}
        RestoreResult try_restore(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action) override
        {
            const auto& abi_tag = action.package_abi.value_or_exit(VCPKG_LINE_INFO);
            auto& spec = action.spec;
            auto& fs = paths.get_filesystem();
            std::error_code ec;
            const fs::path archives_root_dir = paths.root / "archives";
            const std::string archive_name = abi_tag + ".zip";
            const fs::path archive_subpath = fs::u8path(abi_tag.substr(0, 2)) / archive_name;
            const fs::path archive_path = archives_root_dir / archive_subpath;
            const fs::path archive_tombstone_path = archives_root_dir / "fail" / archive_subpath;
            if (fs.exists(archive_path))
            {
                System::print2("Using cached binary package: ", archive_path.u8string(), "\n");

                int archive_result = decompress_archive(paths, spec, archive_path).exit_code;

                if (archive_result != 0)
                {
                    System::print2("Failed to decompress archive package\n");
                    if (action.build_options.purge_decompress_failure == Build::PurgeDecompressFailure::NO)
                    {
                        return RestoreResult::build_failed;
                    }
                    else
                    {
                        System::print2("Purging bad archive\n");
                        fs.remove(archive_path, ec);
                    }
                }
                else
                {
                    return RestoreResult::success;
                }
            }

            if (fs.exists(archive_tombstone_path))
            {
                if (action.build_options.fail_on_tombstone == Build::FailOnTombstone::YES)
                {
                    System::print2("Found failure tombstone: ", archive_tombstone_path.u8string(), "\n");
                    return RestoreResult::build_failed;
                }
                else
                {
                    System::print2(
                        System::Color::warning, "Found failure tombstone: ", archive_tombstone_path.u8string(), "\n");
                }
            }
            else
            {
                System::printf("Could not locate cached archive: %s\n", archive_path.u8string());
            }

            return RestoreResult::missing;
        }
        void push_success(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action) override
        {
            const auto& abi_tag = action.package_abi.value_or_exit(VCPKG_LINE_INFO);
            auto& spec = action.spec;
            auto& fs = paths.get_filesystem();
            std::error_code ec;
            const fs::path archives_root_dir = paths.root / "archives";
            const std::string archive_name = abi_tag + ".zip";
            const fs::path archive_subpath = fs::u8path(abi_tag.substr(0, 2)) / archive_name;
            const fs::path archive_path = archives_root_dir / archive_subpath;

            const auto tmp_archive_path = paths.buildtrees / spec.name() / (spec.triplet().to_string() + ".zip");

            compress_directory(paths, paths.package_dir(spec), tmp_archive_path);

            fs.create_directories(archive_path.parent_path(), ec);
            fs.rename_or_copy(tmp_archive_path, archive_path, ".tmp", ec);
            if (ec)
            {
                System::printf(System::Color::warning,
                               "Failed to store binary cache %s: %s\n",
                               archive_path.u8string(),
                               ec.message());
            }
            else
                System::printf("Stored binary cache: %s\n", archive_path.u8string());
        }
        void push_failure(const VcpkgPaths& paths, const std::string& abi_tag, const PackageSpec& spec) override
        {
            auto& fs = paths.get_filesystem();
            std::error_code ec;
            const fs::path archives_root_dir = paths.root / "archives";
            const std::string archive_name = abi_tag + ".zip";
            const fs::path archive_subpath = fs::u8path(abi_tag.substr(0, 2)) / archive_name;
            const fs::path archive_path = archives_root_dir / archive_subpath;
            const fs::path archive_tombstone_path = archives_root_dir / "fail" / archive_subpath;
            const fs::path abi_package_dir = paths.package_dir(spec) / "share" / spec.name();
            const fs::path abi_file_in_package = paths.package_dir(spec) / "share" / spec.name() / "vcpkg_abi_info.txt";

            if (!fs.exists(archive_tombstone_path))
            {
                // Build failed, store all failure logs in the tombstone.
                const auto tmp_log_path = paths.buildtrees / spec.name() / "tmp_failure_logs";
                const auto tmp_log_path_destination = tmp_log_path / spec.name();
                const auto tmp_failure_zip = paths.buildtrees / spec.name() / "failure_logs.zip";
                fs.create_directories(tmp_log_path_destination, ec);

                for (auto& log_file : fs::stdfs::directory_iterator(paths.buildtrees / spec.name()))
                {
                    if (log_file.path().extension() == ".log")
                    {
                        fs.copy_file(log_file.path(),
                                     tmp_log_path_destination / log_file.path().filename(),
                                     fs::stdfs::copy_options::none,
                                     ec);
                    }
                }

                compress_directory(paths, tmp_log_path, paths.buildtrees / spec.name() / "failure_logs.zip");

                fs.create_directories(archive_tombstone_path.parent_path(), ec);
                fs.rename_or_copy(tmp_failure_zip, archive_tombstone_path, ".tmp", ec);

                // clean up temporary directory
                fs.remove_all(tmp_log_path, VCPKG_LINE_INFO);
            }
        }
        RestoreResult precheck(const VcpkgPaths& paths,
                               const Dependencies::InstallPlanAction& action,
                               bool purge_tombstones) override
        {
            const auto& abi_tag = action.package_abi.value_or_exit(VCPKG_LINE_INFO);
            auto& fs = paths.get_filesystem();
            std::error_code ec;
            const fs::path archives_root_dir = paths.root / "archives";
            const std::string archive_name = abi_tag + ".zip";
            const fs::path archive_subpath = fs::u8path(abi_tag.substr(0, 2)) / archive_name;
            const fs::path archive_path = archives_root_dir / archive_subpath;
            const fs::path archive_tombstone_path = archives_root_dir / "fail" / archive_subpath;

            if (fs.exists(archive_path))
            {
                return RestoreResult::success;
            }

            if (purge_tombstones)
            {
                fs.remove(archive_tombstone_path, ec); // Ignore error
            }
            else if (fs.exists(archive_tombstone_path))
            {
                if (action.build_options.fail_on_tombstone == Build::FailOnTombstone::YES)
                {
                    return RestoreResult::build_failed;
                }
            }

            return RestoreResult::missing;
        }
    };
}

std::unique_ptr<vcpkg::IBinaryProvider> vcpkg::create_archives_provider()
{
    return std::make_unique<ArchivesBinaryProvider>();
}
