#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/binarycaching.h>
#include <vcpkg/build.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/parse.h>

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
        ArchivesBinaryProvider(std::vector<fs::path>&& read_dirs, std::vector<fs::path>&& write_dirs)
            : m_read_dirs(std::move(read_dirs)), m_write_dirs(std::move(write_dirs))
        {
        }
        ~ArchivesBinaryProvider() = default;
        void prefetch() override {}
        RestoreResult try_restore(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action) override
        {
            const auto& abi_tag = action.package_abi.value_or_exit(VCPKG_LINE_INFO);
            auto& spec = action.spec;
            auto& fs = paths.get_filesystem();
            std::error_code ec;
            for (auto&& archives_root_dir : m_read_dirs)
            {
                const std::string archive_name = abi_tag + ".zip";
                const fs::path archive_subpath = fs::u8path(abi_tag.substr(0, 2)) / archive_name;
                const fs::path archive_path = archives_root_dir / archive_subpath;
                if (fs.exists(archive_path))
                {
                    System::print2("Using cached binary package: ", archive_path.u8string(), "\n");

                    int archive_result = decompress_archive(paths, spec, archive_path).exit_code;

                    if (archive_result == 0)
                    {
                        return RestoreResult::success;
                    }
                    else
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
                }
            }
            for (auto&& archives_root_dir : m_read_dirs)
            {
                const std::string archive_name = abi_tag + ".zip";
                const fs::path archive_subpath = fs::u8path(abi_tag.substr(0, 2)) / archive_name;
                const fs::path archive_tombstone_path = archives_root_dir / "fail" / archive_subpath;
                if (fs.exists(archive_tombstone_path))
                {
                    if (action.build_options.fail_on_tombstone == Build::FailOnTombstone::YES)
                    {
                        System::print2("Found failure tombstone: ", archive_tombstone_path.u8string(), "\n");
                        return RestoreResult::build_failed;
                    }
                    else
                    {
                        System::print2(System::Color::warning,
                                       "Found failure tombstone: ",
                                       archive_tombstone_path.u8string(),
                                       "\n");
                    }
                }
                else
                {
                    const fs::path archive_path = archives_root_dir / archive_subpath;
                    System::printf("Could not locate cached archive: %s\n", archive_path.u8string());
                }
            }
            return RestoreResult::missing;
        }
        void push_success(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action) override
        {
            if (m_write_dirs.empty()) return;
            const auto& abi_tag = action.package_abi.value_or_exit(VCPKG_LINE_INFO);
            auto& spec = action.spec;
            auto& fs = paths.get_filesystem();
            const auto tmp_archive_path = paths.buildtrees / spec.name() / (spec.triplet().to_string() + ".zip");
            compress_directory(paths, paths.package_dir(spec), tmp_archive_path);

            for (auto&& m_directory : m_write_dirs)
            {
                const fs::path& archives_root_dir = m_directory;
                const std::string archive_name = abi_tag + ".zip";
                const fs::path archive_subpath = fs::u8path(abi_tag.substr(0, 2)) / archive_name;
                const fs::path archive_path = archives_root_dir / archive_subpath;

                fs.create_directories(archive_path.parent_path(), ignore_errors);
                std::error_code ec;
                if (m_write_dirs.size() > 1)
                    fs.copy_file(tmp_archive_path, archive_path, fs::copy_options::overwrite_existing, ec);
                else
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
            if (m_write_dirs.size() > 1) fs.remove(tmp_archive_path, ignore_errors);
        }
        void push_failure(const VcpkgPaths& paths, const std::string& abi_tag, const PackageSpec& spec) override
        {
            if (m_write_dirs.empty()) return;
            auto& fs = paths.get_filesystem();
            std::error_code ec;
            for (auto&& m_directory : m_write_dirs)
            {
                const fs::path& archives_root_dir = m_directory;
                const std::string archive_name = abi_tag + ".zip";
                const fs::path archive_subpath = fs::u8path(abi_tag.substr(0, 2)) / archive_name;
                const fs::path archive_tombstone_path = archives_root_dir / "fail" / archive_subpath;
                if (!fs.exists(archive_tombstone_path))
                {
                    // Build failed, store all failure logs in the tombstone.
                    const auto tmp_log_path = paths.buildtrees / spec.name() / "tmp_failure_logs";
                    const auto tmp_log_path_destination = tmp_log_path / spec.name();
                    const auto tmp_failure_zip = paths.buildtrees / spec.name() / "failure_logs.zip";
                    fs.create_directories(tmp_log_path_destination, ignore_errors);

                    for (auto& log_file : fs::stdfs::directory_iterator(paths.buildtrees / spec.name()))
                    {
                        if (log_file.path().extension() == ".log")
                        {
                            fs.copy_file(log_file.path(),
                                         tmp_log_path_destination / log_file.path().filename(),
                                         fs::copy_options::none,
                                         ec);
                        }
                    }

                    compress_directory(paths, tmp_log_path, paths.buildtrees / spec.name() / "failure_logs.zip");

                    fs.create_directories(archive_tombstone_path.parent_path(), ignore_errors);
                    std::error_code ec;
                    fs.rename_or_copy(tmp_failure_zip, archive_tombstone_path, ".tmp", ec);

                    // clean up temporary directory
                    fs.remove_all(tmp_log_path, VCPKG_LINE_INFO);
                }
            }
        }
        RestoreResult precheck(const VcpkgPaths& paths,
                               const Dependencies::InstallPlanAction& action,
                               bool purge_tombstones) override
        {
            const auto& abi_tag = action.package_abi.value_or_exit(VCPKG_LINE_INFO);
            auto& fs = paths.get_filesystem();
            std::error_code ec;
            for (auto&& archives_root_dir : m_read_dirs)
            {
                const std::string archive_name = abi_tag + ".zip";
                const fs::path archive_subpath = fs::u8path(abi_tag.substr(0, 2)) / archive_name;
                const fs::path archive_path = archives_root_dir / archive_subpath;

                if (fs.exists(archive_path))
                {
                    return RestoreResult::success;
                }
            }
            for (auto&& archives_root_dir : m_read_dirs)
            {
                const std::string archive_name = abi_tag + ".zip";
                const fs::path archive_subpath = fs::u8path(abi_tag.substr(0, 2)) / archive_name;
                const fs::path archive_tombstone_path = archives_root_dir / "fail" / archive_subpath;

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
            }
            return RestoreResult::missing;
        }

        std::vector<fs::path> m_read_dirs, m_write_dirs;
    };
}

ExpectedS<std::unique_ptr<IBinaryProvider>> vcpkg::create_binary_provider_from_configs(const VcpkgPaths& paths,
                                                                                       View<std::string> args)
{
    std::string env_string = System::get_environment_variable("VCPKG_BINARY_SOURCES").value_or("");

    // Preserve existing behavior until CI can be updated
    // TODO: remove
    if (args.size() == 0 && env_string.empty())
    {
        auto p = paths.root / fs::u8path("archives");
        return {std::make_unique<ArchivesBinaryProvider>(std::vector<fs::path>{p}, std::vector<fs::path>{p})};
    }

    return create_binary_provider_from_configs_pure(env_string, args);
}
ExpectedS<std::unique_ptr<IBinaryProvider>> vcpkg::create_binary_provider_from_configs_pure(
    const std::string& env_string, View<std::string> args)
{
    struct BinaryConfigParser : Parse::ParserBase
    {
        std::vector<fs::path> archives_to_read;
        std::vector<fs::path> archives_to_write;

        void parse()
        {
            while (!at_eof())
            {
                std::vector<std::pair<SourceLoc, std::string>> segments;

                for (;;)
                {
                    SourceLoc loc = cur_loc();
                    std::string segment;
                    for (;;)
                    {
                        auto n = match_until([](char ch) { return ch == ',' || ch == '`' || ch == ';'; });
                        Strings::append(segment, n);
                        auto ch = cur();
                        if (ch == '\0' || ch == ',' || ch == ';')
                            break;
                        else if (ch == '`')
                        {
                            ch = next();
                            if (ch == '\0')
                                add_error("unexpected eof: trailing unescaped backticks (`) are not allowed");
                            else
                                segment.push_back(ch);
                            next();
                        }
                        else
                            Checks::unreachable(VCPKG_LINE_INFO);
                    }
                    segments.emplace_back(std::move(loc), std::move(segment));

                    auto ch = cur();
                    if (ch == '\0' || ch == ';')
                        break;
                    else if (ch == ',')
                    {
                        next();
                        continue;
                    }
                    else
                        Checks::unreachable(VCPKG_LINE_INFO);
                }

                if (segments.size() != 1 || !segments[0].second.empty()) handle_segments(std::move(segments));
                segments.clear();
                if (get_error()) return;
                if (cur() == ';') next();
            }
        }

        void handle_segments(std::vector<std::pair<SourceLoc, std::string>>&& segments)
        {
            if (segments.empty()) return;
            if (segments[0].second == "clear")
            {
                if (segments.size() != 1)
                    return add_error("unexpected arguments: binary config 'clear' does not take arguments",
                                     segments[1].first);
                archives_to_read.clear();
                archives_to_write.clear();
            }
            else if (segments[0].second == "files")
            {
                if (segments.size() < 2)
                    return add_error("expected arguments: binary config 'files' requires at least a path argument",
                                     segments[0].first);

                auto p = fs::u8path(segments[1].second);
                if (!p.is_absolute())
                    return add_error("expected arguments: path arguments for binary config strings must be absolute",
                                     segments[1].first);

                if (segments.size() > 3)
                {
                    return add_error("unexpected arguments: binary config 'files' does not take more than 2 arguments",
                                     segments[3].first);
                }
                else if (segments.size() == 3)
                {
                    if (segments[2].second != "upload")
                    {
                        return add_error("unexpected arguments: binary config 'files' can only accept 'upload' as "
                                         "a second argument",
                                         segments[2].first);
                    }
                    else
                    {
                        archives_to_write.push_back(p);
                    }
                }
                archives_to_read.push_back(std::move(p));
            }
            else if (segments[0].second == "default")
            {
                if (segments.size() > 2)
                    return add_error("unexpected arguments: binary config 'default' does not take more than 1 argument",
                                     segments[0].first);

                auto maybe_home = System::get_home_dir();
                if (!maybe_home.has_value()) return add_error(maybe_home.error(), segments[0].first);

                auto p = fs::u8path(maybe_home.value_or_exit(VCPKG_LINE_INFO)) / fs::u8path(".vcpkg/archives");
                if (!p.is_absolute())
                    return add_error("default path was not absolute: " + p.u8string(), segments[0].first);
                if (segments.size() == 2)
                {
                    if (segments[1].second != "upload")
                    {
                        return add_error(
                            "unexpected arguments: binary config 'default' can only accept 'upload' as an argument",
                            segments[1].first);
                    }
                    else
                    {
                        archives_to_write.push_back(p);
                    }
                }
                archives_to_read.push_back(std::move(p));
            }
            else
            {
                return add_error("unknown binary provider type: valid providers are 'clear', 'default', and 'files'",
                                 segments[0].first);
            }
        }
    } parser;

    parser.init(env_string, "VCPKG_BINARY_SOURCES");
    parser.parse();
    for (auto&& arg : args)
    {
        parser.init(arg, "<command>");
        parser.parse();
    }
    if (auto err = parser.get_error())
    {
        return err->format();
    }
    return {std::make_unique<ArchivesBinaryProvider>(std::move(parser.archives_to_read),
                                                     std::move(parser.archives_to_write))};
}
