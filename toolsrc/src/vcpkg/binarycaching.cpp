#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/parse.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>

#include <vcpkg/binarycaching.h>
#include <vcpkg/binarycaching.private.h>
#include <vcpkg/build.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/metrics.h>
#include <vcpkg/tools.h>

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
        Checks::check_exit(VCPKG_LINE_INFO, files.empty(), "unable to clear path: %s", fs::u8string(pkg_path));

#if defined(_WIN32)
        auto&& seven_zip_exe = paths.get_tool_exe(Tools::SEVEN_ZIP);
        auto cmd = Strings::format(R"("%s" x "%s" -o"%s" -y)",
                                   fs::u8string(seven_zip_exe),
                                   fs::u8string(archive_path),
                                   fs::u8string(pkg_path));
#else
        auto cmd = Strings::format(R"(unzip -qq "%s" "-d%s")", fs::u8string(archive_path), fs::u8string(pkg_path));
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
            VCPKG_LINE_INFO, !fs.exists(destination), "Could not remove file: %s", fs::u8string(destination));
#if defined(_WIN32)
        auto&& seven_zip_exe = paths.get_tool_exe(Tools::SEVEN_ZIP);

        System::cmd_execute_and_capture_output(
            Strings::format(
                R"("%s" a "%s" "%s\*")", fs::u8string(seven_zip_exe), fs::u8string(destination), fs::u8string(source)),
            System::get_clean_environment());
#else
        System::cmd_execute_clean(
            Strings::format(R"(cd '%s' && zip --quiet -y -r '%s' *)", fs::u8string(source), fs::u8string(destination)));
#endif
    }

    struct ArchivesBinaryProvider : IBinaryProvider
    {
        ArchivesBinaryProvider(std::vector<fs::path>&& read_dirs, std::vector<fs::path>&& write_dirs)
            : m_read_dirs(std::move(read_dirs)), m_write_dirs(std::move(write_dirs))
        {
        }
        ~ArchivesBinaryProvider() = default;
        void prefetch(const VcpkgPaths&, const Dependencies::ActionPlan&) override { }
        RestoreResult try_restore(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action) override
        {
            const auto& abi_tag = action.abi_info.value_or_exit(VCPKG_LINE_INFO).package_abi;
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
                    System::print2("Using cached binary package: ", fs::u8string(archive_path), "\n");

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

                System::printf("Could not locate cached archive: %s\n", fs::u8string(archive_path));
            }

            return RestoreResult::missing;
        }
        void push_success(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action) override
        {
            if (m_write_dirs.empty()) return;
            const auto& abi_tag = action.abi_info.value_or_exit(VCPKG_LINE_INFO).package_abi;
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
                                   fs::u8string(archive_path),
                                   ec.message());
                }
                else
                    System::printf("Stored binary cache: %s\n", fs::u8string(archive_path));
            }
            if (m_write_dirs.size() > 1) fs.remove(tmp_archive_path, ignore_errors);
        }
        RestoreResult precheck(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action) override
        {
            const auto& abi_tag = action.abi_info.value_or_exit(VCPKG_LINE_INFO).package_abi;
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
            return RestoreResult::missing;
        }

    private:
        std::vector<fs::path> m_read_dirs, m_write_dirs;
    };

    static std::string trim_leading_zeroes(std::string v)
    {
        auto n = v.find_first_not_of('0');
        if (n == std::string::npos)
        {
            v = "0";
        }
        else if (n > 0)
        {
            v.erase(0, n);
        }
        return v;
    }

    struct NugetBinaryProvider : IBinaryProvider
    {
        NugetBinaryProvider(std::vector<std::string>&& read_sources,
                            std::vector<std::string>&& write_sources,
                            std::vector<fs::path>&& read_configs,
                            std::vector<fs::path>&& write_configs,
                            bool interactive)
            : m_read_sources(std::move(read_sources))
            , m_write_sources(std::move(write_sources))
            , m_read_configs(std::move(read_configs))
            , m_write_configs(std::move(write_configs))
            , m_interactive(interactive)
        {
        }
        void prefetch(const VcpkgPaths& paths, const Dependencies::ActionPlan& plan) override
        {
            if (m_read_sources.empty() && m_read_configs.empty()) return;

            auto& fs = paths.get_filesystem();

            std::vector<std::pair<PackageSpec, NugetReference>> nuget_refs;

            for (auto&& action : plan.install_actions)
            {
                if (!action.has_package_abi()) continue;

                auto& spec = action.spec;
                fs.remove_all(paths.package_dir(spec), VCPKG_LINE_INFO);

                nuget_refs.emplace_back(spec, NugetReference(action));
            }

            if (nuget_refs.empty()) return;

            System::print2("Attempting to fetch ", nuget_refs.size(), " packages from nuget.\n");

            auto packages_config = paths.buildtrees / fs::u8path("packages.config");

            auto generate_packages_config = [&] {
                XmlSerializer xml;
                xml.emit_declaration().line_break();
                xml.open_tag("packages").line_break();

                for (auto&& nuget_ref : nuget_refs)
                    xml.start_complex_open_tag("package")
                        .text_attr("id", nuget_ref.second.id)
                        .text_attr("version", nuget_ref.second.version)
                        .finish_self_closing_complex_tag()
                        .line_break();

                xml.close_tag("packages").line_break();
                paths.get_filesystem().write_contents(packages_config, xml.buf, VCPKG_LINE_INFO);
            };

            const auto& nuget_exe = paths.get_tool_exe("nuget");
            std::vector<std::string> cmdlines;

            if (!m_read_sources.empty())
            {
                // First check using all sources
                System::CmdLineBuilder cmdline;
#ifndef _WIN32
                cmdline.path_arg(paths.get_tool_exe(Tools::MONO));
#endif
                cmdline.path_arg(nuget_exe)
                    .string_arg("install")
                    .path_arg(packages_config)
                    .string_arg("-OutputDirectory")
                    .path_arg(paths.packages)
                    .string_arg("-Source")
                    .string_arg(Strings::join(";", m_read_sources))
                    .string_arg("-ExcludeVersion")
                    .string_arg("-NoCache")
                    .string_arg("-PreRelease")
                    .string_arg("-DirectDownload")
                    .string_arg("-PackageSaveMode")
                    .string_arg("nupkg")
                    .string_arg("-Verbosity")
                    .string_arg("detailed")
                    .string_arg("-ForceEnglishOutput");
                if (!m_interactive) cmdline.string_arg("-NonInteractive");
                cmdlines.push_back(cmdline.extract());
            }
            for (auto&& cfg : m_read_configs)
            {
                // Then check using each config
                System::CmdLineBuilder cmdline;
#ifndef _WIN32
                cmdline.path_arg(paths.get_tool_exe(Tools::MONO));
#endif
                cmdline.path_arg(nuget_exe)
                    .string_arg("install")
                    .path_arg(packages_config)
                    .string_arg("-OutputDirectory")
                    .path_arg(paths.packages)
                    .string_arg("-ConfigFile")
                    .path_arg(cfg)
                    .string_arg("-ExcludeVersion")
                    .string_arg("-NoCache")
                    .string_arg("-PreRelease")
                    .string_arg("-DirectDownload")
                    .string_arg("-PackageSaveMode")
                    .string_arg("nupkg")
                    .string_arg("-Verbosity")
                    .string_arg("detailed")
                    .string_arg("-ForceEnglishOutput");
                if (!m_interactive) cmdline.string_arg("-NonInteractive");
                cmdlines.push_back(cmdline.extract());
            }

            size_t num_restored = 0;

            for (const auto& cmdline : cmdlines)
            {
                if (nuget_refs.empty()) break;

                [&] {
                    generate_packages_config();
                    if (Debug::g_debugging)
                        System::cmd_execute(cmdline);
                    else
                    {
                        auto res = System::cmd_execute_and_capture_output(cmdline);
                        if (res.output.find("Authentication may require manual action.") != std::string::npos)
                        {
                            System::print2(
                                System::Color::warning,
                                "One or more NuGet credential providers requested manual action. Add the binary "
                                "source 'interactive' to allow interactivity.\n");
                        }
                    }
                }();

                Util::erase_remove_if(nuget_refs, [&](const std::pair<PackageSpec, NugetReference>& nuget_ref) -> bool {
                    auto nupkg_path = paths.package_dir(nuget_ref.first) / fs::u8path(nuget_ref.second.id + ".nupkg");
                    if (fs.exists(nupkg_path, ignore_errors))
                    {
                        fs.remove(nupkg_path, VCPKG_LINE_INFO);
                        Checks::check_exit(VCPKG_LINE_INFO,
                                           !fs.exists(nupkg_path, ignore_errors),
                                           "Unable to remove nupkg after restoring: %s",
                                           fs::u8string(nupkg_path));
                        m_restored.emplace(nuget_ref.first);
                        ++num_restored;
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                });
            }

            System::print2("Restored ", num_restored, " packages. Use --debug for more information.\n");
        }
        RestoreResult try_restore(const VcpkgPaths&, const Dependencies::InstallPlanAction& action) override
        {
            if (Util::Sets::contains(m_restored, action.spec))
                return RestoreResult::success;
            else
                return RestoreResult::missing;
        }
        void push_success(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action) override
        {
            if (m_write_sources.empty() && m_write_configs.empty()) return;
            auto& spec = action.spec;

            NugetReference nuget_ref(action);
            auto nuspec_path = paths.buildtrees / spec.name() / (spec.triplet().to_string() + ".nuspec");
            paths.get_filesystem().write_contents(
                nuspec_path, generate_nuspec(paths, action, nuget_ref), VCPKG_LINE_INFO);

            const auto& nuget_exe = paths.get_tool_exe("nuget");
            System::CmdLineBuilder cmdline;
#ifndef _WIN32
            cmdline.path_arg(paths.get_tool_exe(Tools::MONO));
#endif
            cmdline.path_arg(nuget_exe)
                .string_arg("pack")
                .path_arg(nuspec_path)
                .string_arg("-OutputDirectory")
                .path_arg(paths.buildtrees)
                .string_arg("-NoDefaultExcludes")
                .string_arg("-ForceEnglishOutput");
            if (!m_interactive) cmdline.string_arg("-NonInteractive");

            auto pack_rc = [&] {
                if (Debug::g_debugging)
                    return System::cmd_execute(cmdline);
                else
                    return System::cmd_execute_and_capture_output(cmdline).exit_code;
            }();

            if (pack_rc != 0)
            {
                System::print2(System::Color::error, "Packing NuGet failed. Use --debug for more information.\n");
            }
            else
            {
                auto nupkg_path = paths.buildtrees / nuget_ref.nupkg_filename();
                for (auto&& write_src : m_write_sources)
                {
                    System::CmdLineBuilder cmd;
#ifndef _WIN32
                    cmd.path_arg(paths.get_tool_exe(Tools::MONO));
#endif
                    cmd.path_arg(nuget_exe)
                        .string_arg("push")
                        .path_arg(nupkg_path)
                        .string_arg("-ApiKey")
                        .string_arg("AzureDevOps")
                        .string_arg("-ForceEnglishOutput")
                        .string_arg("-Source")
                        .string_arg(write_src);
                    if (!m_interactive) cmd.string_arg("-NonInteractive");

                    System::print2("Uploading binaries for ", spec, " to NuGet source ", write_src, ".\n");

                    auto rc = [&] {
                        if (Debug::g_debugging)
                            return System::cmd_execute(cmd);
                        else
                            return System::cmd_execute_and_capture_output(cmd).exit_code;
                    }();

                    if (rc != 0)
                    {
                        System::print2(System::Color::error,
                                       "Pushing NuGet to ",
                                       write_src,
                                       " failed. Use --debug for more information.\n");
                    }
                }
                for (auto&& write_cfg : m_write_configs)
                {
                    System::CmdLineBuilder cmd;
#ifndef _WIN32
                    cmd.path_arg(paths.get_tool_exe(Tools::MONO));
#endif
                    cmd.path_arg(nuget_exe)
                        .string_arg("push")
                        .path_arg(nupkg_path)
                        .string_arg("-ApiKey")
                        .string_arg("AzureDevOps")
                        .string_arg("-ForceEnglishOutput")
                        .string_arg("-ConfigFile")
                        .path_arg(write_cfg);
                    if (!m_interactive) cmd.string_arg("-NonInteractive");

                    System::print2(
                        "Uploading binaries for ", spec, " using NuGet config ", fs::u8string(write_cfg), ".\n");

                    auto rc = [&] {
                        if (Debug::g_debugging)
                            return System::cmd_execute(cmd);
                        else
                            return System::cmd_execute_and_capture_output(cmd).exit_code;
                    }();

                    if (rc != 0)
                    {
                        System::print2(System::Color::error,
                                       "Pushing NuGet with ",
                                       fs::u8string(write_cfg),
                                       " failed. Use --debug for more information.\n");
                    }
                }
                paths.get_filesystem().remove(nupkg_path, ignore_errors);
            }
        }
        RestoreResult precheck(const VcpkgPaths&, const Dependencies::InstallPlanAction&) override
        {
            return RestoreResult::missing;
        }

    private:
        std::vector<std::string> m_read_sources;
        std::vector<std::string> m_write_sources;

        std::vector<fs::path> m_read_configs;
        std::vector<fs::path> m_write_configs;

        std::set<PackageSpec> m_restored;
        bool m_interactive;
    };

    struct MergeBinaryProviders : IBinaryProvider
    {
        explicit MergeBinaryProviders(std::vector<std::unique_ptr<IBinaryProvider>>&& providers)
            : m_providers(std::move(providers))
        {
        }

        void prefetch(const VcpkgPaths& paths, const Dependencies::ActionPlan& plan) override
        {
            for (auto&& provider : m_providers)
            {
                provider->prefetch(paths, plan);
            }
        }
        RestoreResult try_restore(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action) override
        {
            for (auto&& provider : m_providers)
            {
                auto result = provider->try_restore(paths, action);
                switch (result)
                {
                    case RestoreResult::build_failed:
                    case RestoreResult::success: return result;
                    case RestoreResult::missing: continue;
                    default: Checks::unreachable(VCPKG_LINE_INFO);
                }
            }
            return RestoreResult::missing;
        }
        void push_success(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action) override
        {
            for (auto&& provider : m_providers)
            {
                provider->push_success(paths, action);
            }
        }
        RestoreResult precheck(const VcpkgPaths& paths, const Dependencies::InstallPlanAction& action) override
        {
            for (auto&& provider : m_providers)
            {
                auto result = provider->precheck(paths, action);
                switch (result)
                {
                    case RestoreResult::build_failed:
                    case RestoreResult::success: return result;
                    case RestoreResult::missing: continue;
                    default: Checks::unreachable(VCPKG_LINE_INFO);
                }
            }
            return RestoreResult::missing;
        }

    private:
        std::vector<std::unique_ptr<IBinaryProvider>> m_providers;
    };

    struct NullBinaryProvider : IBinaryProvider
    {
        void prefetch(const VcpkgPaths&, const Dependencies::ActionPlan&) override { }
        RestoreResult try_restore(const VcpkgPaths&, const Dependencies::InstallPlanAction&) override
        {
            return RestoreResult::missing;
        }
        void push_success(const VcpkgPaths&, const Dependencies::InstallPlanAction&) override { }
        RestoreResult precheck(const VcpkgPaths&, const Dependencies::InstallPlanAction&) override
        {
            return RestoreResult::missing;
        }
    };
}

XmlSerializer& XmlSerializer::emit_declaration()
{
    buf.append(R"(<?xml version="1.0" encoding="utf-8"?>)");
    return *this;
}
XmlSerializer& XmlSerializer::open_tag(StringLiteral sl)
{
    emit_pending_indent();
    Strings::append(buf, '<', sl, '>');
    m_indent += 2;
    return *this;
}
XmlSerializer& XmlSerializer::start_complex_open_tag(StringLiteral sl)
{
    emit_pending_indent();
    Strings::append(buf, '<', sl);
    m_indent += 2;
    return *this;
}
XmlSerializer& XmlSerializer::text_attr(StringLiteral name, StringView content)
{
    if (m_pending_indent)
    {
        m_pending_indent = false;
        buf.append(m_indent, ' ');
    }
    else
    {
        buf.push_back(' ');
    }
    Strings::append(buf, name, "=\"");
    text(content);
    Strings::append(buf, '"');
    return *this;
}
XmlSerializer& XmlSerializer::finish_complex_open_tag()
{
    emit_pending_indent();
    Strings::append(buf, '>');
    return *this;
}
XmlSerializer& XmlSerializer::finish_self_closing_complex_tag()
{
    emit_pending_indent();
    Strings::append(buf, "/>");
    m_indent -= 2;
    return *this;
}
XmlSerializer& XmlSerializer::close_tag(StringLiteral sl)
{
    m_indent -= 2;
    emit_pending_indent();
    Strings::append(buf, "</", sl, '>');
    return *this;
}
XmlSerializer& XmlSerializer::text(StringView sv)
{
    emit_pending_indent();
    for (auto ch : sv)
    {
        if (ch == '&')
        {
            buf.append("&amp;");
        }
        else if (ch == '<')
        {
            buf.append("&lt;");
        }
        else if (ch == '>')
        {
            buf.append("&gt;");
        }
        else if (ch == '"')
        {
            buf.append("&quot;");
        }
        else if (ch == '\'')
        {
            buf.append("&apos;");
        }
        else
        {
            buf.push_back(ch);
        }
    }
    return *this;
}
XmlSerializer& XmlSerializer::simple_tag(StringLiteral tag, StringView content)
{
    return emit_pending_indent().open_tag(tag).text(content).close_tag(tag);
}
XmlSerializer& XmlSerializer::line_break()
{
    buf.push_back('\n');
    m_pending_indent = true;
    return *this;
}
XmlSerializer& XmlSerializer::emit_pending_indent()
{
    if (m_pending_indent)
    {
        m_pending_indent = false;
        buf.append(m_indent, ' ');
    }
    return *this;
}

IBinaryProvider& vcpkg::null_binary_provider()
{
    static NullBinaryProvider p;
    return p;
}

ExpectedS<std::unique_ptr<IBinaryProvider>> vcpkg::create_binary_provider_from_configs(View<std::string> args)
{
    std::string env_string = System::get_environment_variable("VCPKG_BINARY_SOURCES").value_or("");

    return create_binary_provider_from_configs_pure(env_string, args);
}
namespace
{
    const ExpectedS<fs::path>& default_cache_path()
    {
        static auto cachepath = System::get_platform_cache_home().then([](fs::path p) -> ExpectedS<fs::path> {
            auto maybe_cachepath = System::get_environment_variable("VCPKG_DEFAULT_BINARY_CACHE");
            if (auto p_str = maybe_cachepath.get())
            {
                Metrics::g_metrics.lock()->track_property("VCPKG_DEFAULT_BINARY_CACHE", "defined");
                auto path = fs::u8path(*p_str);
                path.make_preferred();
                const auto status = fs::stdfs::status(path);
                if (!fs::stdfs::exists(status))
                    return {"Path to VCPKG_DEFAULT_BINARY_CACHE does not exist: " + fs::u8string(path),
                            expected_right_tag};
                if (!fs::stdfs::is_directory(status))
                    return {"Value of environment variable VCPKG_DEFAULT_BINARY_CACHE is not a directory: " +
                                fs::u8string(path),
                            expected_right_tag};
                if (!path.is_absolute())
                    return {"Value of environment variable VCPKG_DEFAULT_BINARY_CACHE is not absolute: " +
                                fs::u8string(path),
                            expected_right_tag};
                return {std::move(path), expected_left_tag};
            }
            p /= fs::u8path("vcpkg/archives");
            p.make_preferred();
            if (p.is_absolute())
            {
                return {std::move(p), expected_left_tag};
            }
            else
            {
                return {"default path was not absolute: " + fs::u8string(p), expected_right_tag};
            }
        });
        if (cachepath.has_value())
            Debug::print("Default binary cache path is: ", fs::u8string(*cachepath.get()), '\n');
        else
            Debug::print("No binary cache path. Reason: ", cachepath.error(), '\n');
        return cachepath;
    }

    struct State
    {
        bool m_cleared = false;
        bool interactive = false;

        std::vector<fs::path> archives_to_read;
        std::vector<fs::path> archives_to_write;

        std::vector<std::string> sources_to_read;
        std::vector<std::string> sources_to_write;

        std::vector<fs::path> configs_to_read;
        std::vector<fs::path> configs_to_write;

        void clear()
        {
            m_cleared = true;
            interactive = false;
            archives_to_read.clear();
            archives_to_write.clear();
            sources_to_read.clear();
            sources_to_write.clear();
            configs_to_read.clear();
            configs_to_write.clear();
        }
    };

    struct BinaryConfigParser : Parse::ParserBase
    {
        BinaryConfigParser(StringView text, StringView origin, State* state)
            : Parse::ParserBase(text, origin), state(state)
        {
        }

        State* state;

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
                        auto n = match_until([](char32_t ch) { return ch == ',' || ch == '`' || ch == ';'; });
                        Strings::append(segment, n);
                        auto ch = cur();
                        if (ch == Unicode::end_of_file || ch == ',' || ch == ';')
                            break;
                        else if (ch == '`')
                        {
                            ch = next();
                            if (ch == Unicode::end_of_file)
                                add_error("unexpected eof: trailing unescaped backticks (`) are not allowed");
                            else
                                Unicode::utf8_append_code_point(segment, ch);
                            next();
                        }
                        else
                            Checks::unreachable(VCPKG_LINE_INFO);
                    }
                    segments.emplace_back(std::move(loc), std::move(segment));

                    auto ch = cur();
                    if (ch == Unicode::end_of_file || ch == ';')
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

        template<class T>
        void handle_readwrite(std::vector<T>& read,
                              std::vector<T>& write,
                              T&& t,
                              const std::vector<std::pair<SourceLoc, std::string>>& segments,
                              size_t segment_idx)
        {
            if (segment_idx >= segments.size())
            {
                read.push_back(std::move(t));
                return;
            }

            auto& mode = segments[segment_idx].second;

            if (mode == "read")
            {
                read.push_back(std::move(t));
            }
            else if (mode == "write")
            {
                write.push_back(std::move(t));
            }
            else if (mode == "readwrite")
            {
                read.push_back(t);
                write.push_back(std::move(t));
            }
            else
            {
                return add_error("unexpected argument: expected 'read', readwrite', or 'write'",
                                 segments[segment_idx].first);
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
                state->clear();
            }
            else if (segments[0].second == "files")
            {
                if (segments.size() < 2)
                {
                    return add_error("expected arguments: binary config 'files' requires at least a path argument",
                                     segments[0].first);
                }

                auto p = fs::u8path(segments[1].second);
                if (!p.is_absolute())
                {
                    return add_error("expected arguments: path arguments for binary config strings must be absolute",
                                     segments[1].first);
                }
                handle_readwrite(state->archives_to_read, state->archives_to_write, std::move(p), segments, 2);
                if (segments.size() > 3)
                    return add_error("unexpected arguments: binary config 'files' requires 1 or 2 arguments",
                                     segments[3].first);
            }
            else if (segments[0].second == "interactive")
            {
                if (segments.size() > 1)
                    return add_error("unexpected arguments: binary config 'interactive' does not accept any arguments",
                                     segments[1].first);
                state->interactive = true;
            }
            else if (segments[0].second == "nugetconfig")
            {
                if (segments.size() < 2)
                    return add_error(
                        "expected arguments: binary config 'nugetconfig' requires at least a source argument",
                        segments[0].first);

                auto p = fs::u8path(segments[1].second);
                if (!p.is_absolute())
                    return add_error("expected arguments: path arguments for binary config strings must be absolute",
                                     segments[1].first);
                handle_readwrite(state->configs_to_read, state->configs_to_write, std::move(p), segments, 2);
                if (segments.size() > 3)
                    return add_error("unexpected arguments: binary config 'nugetconfig' requires 1 or 2 arguments",
                                     segments[3].first);
            }
            else if (segments[0].second == "nuget")
            {
                if (segments.size() < 2)
                    return add_error("expected arguments: binary config 'nuget' requires at least a source argument",
                                     segments[0].first);

                auto&& p = segments[1].second;
                if (p.empty())
                    return add_error("unexpected arguments: binary config 'nuget' requires non-empty source");

                handle_readwrite(state->sources_to_read, state->sources_to_write, std::move(p), segments, 2);
                if (segments.size() > 3)
                    return add_error("unexpected arguments: binary config 'nuget' requires 1 or 2 arguments",
                                     segments[3].first);
            }
            else if (segments[0].second == "default")
            {
                if (segments.size() > 2)
                {
                    return add_error("unexpected arguments: binary config 'default' does not take more than 1 argument",
                                     segments[0].first);
                }

                const auto& maybe_home = default_cache_path();
                if (!maybe_home.has_value()) return add_error(maybe_home.error(), segments[0].first);

                handle_readwrite(
                    state->archives_to_read, state->archives_to_write, fs::path(*maybe_home.get()), segments, 1);
            }
            else
            {
                return add_error(
                    "unknown binary provider type: valid providers are 'clear', 'default', 'nuget', 'nugetconfig', "
                    "'interactive', and 'files'",
                    segments[0].first);
            }
        }
    };
}

ExpectedS<std::unique_ptr<IBinaryProvider>> vcpkg::create_binary_provider_from_configs_pure(
    const std::string& env_string, View<std::string> args)
{
    {
        auto metrics = Metrics::g_metrics.lock();
        if (!env_string.empty()) metrics->track_property("VCPKG_BINARY_SOURCES", "defined");
        if (args.size() != 0) metrics->track_property("binarycaching-source", "defined");
    }

    State s;

    BinaryConfigParser default_parser("default,readwrite", "<defaults>", &s);
    default_parser.parse();

    BinaryConfigParser env_parser(env_string, "VCPKG_BINARY_SOURCES", &s);
    env_parser.parse();
    if (auto err = env_parser.get_error()) return err->format();
    for (auto&& arg : args)
    {
        BinaryConfigParser arg_parser(arg, "<command>", &s);
        arg_parser.parse();
        if (auto err = arg_parser.get_error()) return err->format();
    }

    if (s.m_cleared) Metrics::g_metrics.lock()->track_property("binarycaching-clear", "defined");

    std::vector<std::unique_ptr<IBinaryProvider>> providers;
    if (!s.archives_to_read.empty() || !s.archives_to_write.empty())
        providers.push_back(
            std::make_unique<ArchivesBinaryProvider>(std::move(s.archives_to_read), std::move(s.archives_to_write)));
    if (!s.sources_to_read.empty() || !s.sources_to_write.empty() || !s.configs_to_read.empty() ||
        !s.configs_to_write.empty())
    {
        Metrics::g_metrics.lock()->track_property("binarycaching-nuget", "defined");
        providers.push_back(std::make_unique<NugetBinaryProvider>(std::move(s.sources_to_read),
                                                                  std::move(s.sources_to_write),
                                                                  std::move(s.configs_to_read),
                                                                  std::move(s.configs_to_write),
                                                                  s.interactive));
    }

    return {std::make_unique<MergeBinaryProviders>(std::move(providers))};
}

std::string vcpkg::reformat_version(const std::string& version, const std::string& abi_tag)
{
    static const std::regex semver_matcher(R"(v?(\d+)(\.\d+|$)(\.\d+)?.*)");

    std::smatch sm;
    if (std::regex_match(version.cbegin(), version.cend(), sm, semver_matcher))
    {
        auto major = trim_leading_zeroes(sm.str(1));
        auto minor = sm.size() > 2 && !sm.str(2).empty() ? trim_leading_zeroes(sm.str(2).substr(1)) : "0";
        auto patch = sm.size() > 3 && !sm.str(3).empty() ? trim_leading_zeroes(sm.str(3).substr(1)) : "0";
        return Strings::concat(major, '.', minor, '.', patch, "-", abi_tag);
    }

    static const std::regex date_matcher(R"((\d\d\d\d)-(\d\d)-(\d\d).*)");
    if (std::regex_match(version.cbegin(), version.cend(), sm, date_matcher))
    {
        return Strings::concat(trim_leading_zeroes(sm.str(1)),
                               '.',
                               trim_leading_zeroes(sm.str(2)),
                               '.',
                               trim_leading_zeroes(sm.str(3)),
                               "-",
                               abi_tag);
    }

    return Strings::concat("0.0.0-", abi_tag);
}

details::NuGetRepoInfo details::get_nuget_repo_info_from_env()
{
    auto vcpkg_nuget_repository = System::get_environment_variable("VCPKG_NUGET_REPOSITORY");
    if (auto p = vcpkg_nuget_repository.get())
    {
        Metrics::g_metrics.lock()->track_property("VCPKG_NUGET_REPOSITORY", "defined");
        return {std::move(*p)};
    }
    auto gh_repo = System::get_environment_variable("GITHUB_REPOSITORY").value_or("");
    if (gh_repo.empty()) return {};
    auto gh_server = System::get_environment_variable("GITHUB_SERVER_URL").value_or("");
    if (gh_server.empty()) return {};

    Metrics::g_metrics.lock()->track_property("GITHUB_REPOSITORY", "defined");

    return {Strings::concat(gh_server, '/', gh_repo, ".git"),
            System::get_environment_variable("GITHUB_REF").value_or(""),
            System::get_environment_variable("GITHUB_SHA").value_or("")};
}

std::string vcpkg::generate_nuspec(const VcpkgPaths& paths,
                                   const Dependencies::InstallPlanAction& action,
                                   const vcpkg::NugetReference& ref,
                                   details::NuGetRepoInfo rinfo)
{
    auto& spec = action.spec;
    auto& scf = *action.source_control_file_location.value_or_exit(VCPKG_LINE_INFO).source_control_file;
    auto& version = scf.core_paragraph->version;
    const auto& abi_info = action.abi_info.value_or_exit(VCPKG_LINE_INFO);
    const auto& compiler_info = abi_info.compiler_info.value_or_exit(VCPKG_LINE_INFO);
    std::string description =
        Strings::concat("NOT FOR DIRECT USE. Automatically generated cache package.\n\n",
                        Strings::join("\n    ", scf.core_paragraph->description),
                        "\n\nVersion: ",
                        version,
                        "\nTriplet: ",
                        spec.triplet().to_string(),
                        "\nCXX Compiler id: ",
                        compiler_info.id,
                        "\nCXX Compiler version: ",
                        compiler_info.version,
                        "\nTriplet/Compiler hash: ",
                        abi_info.triplet_abi.value_or_exit(VCPKG_LINE_INFO),
                        "\nFeatures:",
                        Strings::join(",", action.feature_list, [](const std::string& s) { return " " + s; }),
                        "\nDependencies:\n");

    for (auto&& dep : action.package_dependencies)
    {
        Strings::append(description, "    ", dep.name(), '\n');
    }
    XmlSerializer xml;
    xml.open_tag("package").line_break();
    xml.open_tag("metadata").line_break();
    xml.simple_tag("id", ref.id).line_break();
    xml.simple_tag("version", ref.version).line_break();
    if (!scf.core_paragraph->homepage.empty()) xml.simple_tag("projectUrl", scf.core_paragraph->homepage);
    xml.simple_tag("authors", "vcpkg").line_break();
    xml.simple_tag("description", description).line_break();
    xml.open_tag("packageTypes");
    xml.start_complex_open_tag("packageType").text_attr("name", "vcpkg").finish_self_closing_complex_tag();
    xml.close_tag("packageTypes").line_break();
    if (!rinfo.repo.empty())
    {
        xml.start_complex_open_tag("repository").text_attr("type", "git").text_attr("url", rinfo.repo);
        if (!rinfo.branch.empty()) xml.text_attr("branch", rinfo.branch);
        if (!rinfo.commit.empty()) xml.text_attr("commit", rinfo.commit);
        xml.finish_self_closing_complex_tag().line_break();
    }
    xml.close_tag("metadata").line_break();
    xml.open_tag("files");
    xml.start_complex_open_tag("file")
        .text_attr("src", fs::u8string(paths.package_dir(spec) / fs::u8path("**")))
        .text_attr("target", "")
        .finish_self_closing_complex_tag();
    xml.close_tag("files").line_break();
    xml.close_tag("package").line_break();
    return std::move(xml.buf);
}

void vcpkg::help_topic_binary_caching(const VcpkgPaths&)
{
    HelpTableFormatter tbl;
    tbl.text("Vcpkg can cache compiled packages to accelerate restoration on a single machine or across the network."
             " This functionality is currently enabled by default and can be disabled by either passing "
             "`--no-binarycaching` to every vcpkg command line or setting the environment variable "
             "`VCPKG_FEATURE_FLAGS` to `-binarycaching`.");
    tbl.blank();
    tbl.blank();
    tbl.text(
        "Once caching is enabled, it can be further configured by either passing `--binarysource=<source>` options "
        "to every command line or setting the `VCPKG_BINARY_SOURCES` environment variable to a set of sources (Ex: "
        "\"<source>;<source>;...\"). Command line sources are interpreted after environment sources.");
    tbl.blank();
    tbl.blank();
    tbl.header("Valid source strings");
    tbl.format("clear", "Removes all previous sources");
    tbl.format("default[,<rw>]", "Adds the default file-based location.");
    tbl.format("files,<path>[,<rw>]", "Adds a custom file-based location.");
    tbl.format("nuget,<uri>[,<rw>]",
               "Adds a NuGet-based source; equivalent to the `-Source` parameter of the NuGet CLI.");
    tbl.format("nugetconfig,<path>[,<rw>]",
               "Adds a NuGet-config-file-based source; equivalent to the `-Config` parameter of the NuGet CLI. This "
               "config should specify `defaultPushSource` for uploads.");
    tbl.format("interactive", "Enables interactive credential management for some source types");
    tbl.blank();
    tbl.text("The `<rw>` optional parameter for certain strings controls whether they will be consulted for "
             "downloading binaries and whether on-demand builds will be uploaded to that remote. It can be specified "
             "as 'read', 'write', or 'readwrite'.");
    tbl.blank();
    tbl.text("The `nuget` and `nugetconfig` source providers additionally respect certain environment variables while "
             "generating nuget packages. The `metadata.repository` field will be optionally generated like:\n"
             "\n"
             "    <repository type=\"git\" url=\"$VCPKG_NUGET_REPOSITORY\"/>\n"
             "or\n"
             "    <repository type=\"git\"\n"
             "                url=\"${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}.git\"\n"
             "                branch=\"${GITHUB_REF}\"\n"
             "                commit=\"${GITHUB_SHA}\"/>\n"
             "\n"
             "if the appropriate environment variables are defined and non-empty.\n");
    tbl.blank();
    System::print2(tbl.m_str);
    const auto& maybe_cachepath = default_cache_path();
    if (auto p = maybe_cachepath.get())
    {
        System::print2(
            "\nBased on your system settings, the default path to store binaries is\n    ",
            fs::u8string(*p),
            "\nThis consults %LOCALAPPDATA%/%APPDATA% on Windows and $XDG_CACHE_HOME or $HOME on other platforms.\n");
    }
    System::print2("\nExtended documentation is available at "
                   "https://github.com/Microsoft/vcpkg/tree/master/docs/users/binarycaching.md \n");
}

std::string vcpkg::generate_nuget_packages_config(const Dependencies::ActionPlan& action)
{
    auto refs = Util::fmap(action.install_actions,
                           [&](const Dependencies::InstallPlanAction& ipa) { return NugetReference(ipa); });
    XmlSerializer xml;
    xml.emit_declaration().line_break();
    xml.open_tag("packages").line_break();
    for (auto&& ref : refs)
    {
        xml.start_complex_open_tag("package")
            .text_attr("id", ref.id)
            .text_attr("version", ref.version)
            .finish_self_closing_complex_tag()
            .line_break();
    }
    xml.close_tag("packages").line_break();
    return std::move(xml.buf);
}
