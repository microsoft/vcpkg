#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>
#include <vcpkg/base/work_queue.h>

#if !defined(_WIN32)
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#endif
#if defined(__linux__)
#include <sys/sendfile.h>
#elif defined(__APPLE__)
#include <copyfile.h>
#endif

namespace vcpkg::Files
{
    static const std::regex FILESYSTEM_INVALID_CHARACTERS_REGEX = std::regex(R"([\/:*?"<>|])");

    namespace
    {
        fs::file_status status_implementation(bool follow_symlinks, const fs::path& p, std::error_code& ec) noexcept
        {
            using fs::file_type;
            using fs::perms;
#if defined(_WIN32)
            WIN32_FILE_ATTRIBUTE_DATA file_attributes;
            auto ft = file_type::unknown;
            auto permissions = perms::unknown;
            if (!GetFileAttributesExW(p.c_str(), GetFileExInfoStandard, &file_attributes))
            {
                const auto err = GetLastError();
                if (err == ERROR_FILE_NOT_FOUND || err == ERROR_PATH_NOT_FOUND)
                {
                    ft = file_type::not_found;
                }
                else
                {
                    ec.assign(err, std::system_category());
                }
            }
            else if (!follow_symlinks && file_attributes.dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT)
            {
                // this also gives junctions file_type::directory_symlink
                if (file_attributes.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
                {
                    ft = file_type::directory_symlink;
                }
                else
                {
                    ft = file_type::symlink;
                }
            }
            else if (file_attributes.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
            {
                ft = file_type::directory;
            }
            else
            {
                // otherwise, the file is a regular file
                ft = file_type::regular;
            }

            if (file_attributes.dwFileAttributes & FILE_ATTRIBUTE_READONLY)
            {
                constexpr auto all_write = perms::group_write | perms::owner_write | perms::others_write;
                permissions = perms::all & ~all_write;
            }
            else if (ft != file_type::none && ft != file_type::none)
            {
                permissions = perms::all;
            }

            return fs::file_status(ft, permissions);

#else
            auto result = follow_symlinks ? fs::stdfs::status(p, ec) : fs::stdfs::symlink_status(p, ec);
            // libstdc++ doesn't correctly not-set ec on nonexistent paths
            if (ec.value() == ENOENT || ec.value() == ENOTDIR)
            {
                ec.clear();
                return fs::file_status(file_type::not_found, perms::unknown);
            }
            return fs::file_status(result.type(), result.permissions());
#endif
        }

        fs::file_status status(const fs::path& p, std::error_code& ec) noexcept
        {
            return status_implementation(true, p, ec);
        }
        fs::file_status symlink_status(const fs::path& p, std::error_code& ec) noexcept
        {
            return status_implementation(false, p, ec);
        }

        // does _not_ follow symlinks
        void set_writeable(const fs::path& path, std::error_code& ec) noexcept
        {
#if defined(_WIN32)
            auto const file_name = path.c_str();
            WIN32_FILE_ATTRIBUTE_DATA attributes;
            if (!GetFileAttributesExW(file_name, GetFileExInfoStandard, &attributes))
            {
                ec.assign(GetLastError(), std::system_category());
                return;
            }

            auto dw_attributes = attributes.dwFileAttributes;
            dw_attributes &= ~FILE_ATTRIBUTE_READONLY;
            if (!SetFileAttributesW(file_name, dw_attributes))
            {
                ec.assign(GetLastError(), std::system_category());
            }
#else
            struct stat s;
            if (lstat(path.c_str(), &s))
            {
                ec.assign(errno, std::system_category());
                return;
            }

            auto mode = s.st_mode;
            // if the file is a symlink, perms don't matter
            if (!(mode & S_IFLNK))
            {
                mode |= S_IWUSR;
                if (chmod(path.c_str(), mode))
                {
                    ec.assign(errno, std::system_category());
                }
            }
#endif
        }
    }

    std::string Filesystem::read_contents(const fs::path& path, LineInfo linfo) const
    {
        auto maybe_contents = this->read_contents(path);
        if (auto p = maybe_contents.get())
            return std::move(*p);
        else
            Checks::exit_with_message(
                linfo, "error reading file: %s: %s", path.u8string(), maybe_contents.error().message());
    }
    void Filesystem::write_contents(const fs::path& path, const std::string& data, LineInfo linfo)
    {
        std::error_code ec;
        this->write_contents(path, data, ec);
        if (ec) Checks::exit_with_message(linfo, "error writing file: %s: %s", path.u8string(), ec.message());
    }
    void Filesystem::rename(const fs::path& oldpath, const fs::path& newpath, LineInfo linfo)
    {
        std::error_code ec;
        this->rename(oldpath, newpath, ec);
        if (ec)
            Checks::exit_with_message(
                linfo, "error renaming file: %s: %s: %s", oldpath.u8string(), newpath.u8string(), ec.message());
    }

    bool Filesystem::remove(const fs::path& path, LineInfo linfo)
    {
        std::error_code ec;
        auto r = this->remove(path, ec);
        if (ec) Checks::exit_with_message(linfo, "error removing file: %s: %s", path.u8string(), ec.message());
        return r;
    }

    bool Filesystem::remove(const fs::path& path, ignore_errors_t)
    {
        std::error_code ec;
        return this->remove(path, ec);
    }

    bool Filesystem::exists(const fs::path& path, std::error_code& ec) const
    {
        return fs::exists(this->symlink_status(path, ec));
    }

    bool Filesystem::exists(LineInfo li, const fs::path& path) const
    {
        std::error_code ec;
        auto result = this->exists(path, ec);
        if (ec) Checks::exit_with_message(li, "error checking existence of file %s: %s", path.u8string(), ec.message());
        return result;
    }

    bool Filesystem::exists(const fs::path& path, ignore_errors_t) const
    {
        std::error_code ec;
        return this->exists(path, ec);
    }

    bool Filesystem::create_directory(const fs::path& path, ignore_errors_t)
    {
        std::error_code ec;
        return this->create_directory(path, ec);
    }

    bool Filesystem::create_directories(const fs::path& path, ignore_errors_t)
    {
        std::error_code ec;
        return this->create_directories(path, ec);
    }

    fs::file_status Filesystem::status(vcpkg::LineInfo li, const fs::path& p) const noexcept
    {
        std::error_code ec;
        auto result = this->status(p, ec);
        if (ec) vcpkg::Checks::exit_with_message(li, "error getting status of path %s: %s", p.string(), ec.message());

        return result;
    }

    fs::file_status Filesystem::status(const fs::path& p, ignore_errors_t) const noexcept
    {
        std::error_code ec;
        return this->status(p, ec);
    }

    fs::file_status Filesystem::symlink_status(vcpkg::LineInfo li, const fs::path& p) const noexcept
    {
        std::error_code ec;
        auto result = this->symlink_status(p, ec);
        if (ec) vcpkg::Checks::exit_with_message(li, "error getting status of path %s: %s", p.string(), ec.message());

        return result;
    }

    fs::file_status Filesystem::symlink_status(const fs::path& p, ignore_errors_t) const noexcept
    {
        std::error_code ec;
        return this->symlink_status(p, ec);
    }

    void Filesystem::write_lines(const fs::path& path, const std::vector<std::string>& lines, LineInfo linfo)
    {
        std::error_code ec;
        this->write_lines(path, lines, ec);
        if (ec) Checks::exit_with_message(linfo, "error writing lines: %s: %s", path.u8string(), ec.message());
    }

    void Filesystem::remove_all(const fs::path& path, LineInfo li)
    {
        std::error_code ec;
        fs::path failure_point;

        this->remove_all(path, ec, failure_point);

        if (ec)
        {
            Checks::exit_with_message(li,
                                      "Failure to remove_all(%s) due to file %s: %s",
                                      path.string(),
                                      failure_point.string(),
                                      ec.message());
        }
    }

    void Filesystem::remove_all(const fs::path& path, ignore_errors_t)
    {
        std::error_code ec;
        fs::path failure_point;

        this->remove_all(path, ec, failure_point);
    }

    fs::path Filesystem::absolute(LineInfo li, const fs::path& path) const
    {
        std::error_code ec;
        const auto result = this->absolute(path, ec);
        if (ec) Checks::exit_with_message(li, "Error getting absolute path of %s: %s", path.string(), ec.message());
        return result;
    }

    fs::path Filesystem::canonical(LineInfo li, const fs::path& path) const
    {
        std::error_code ec;

        const auto result = this->canonical(path, ec);

        if (ec) Checks::exit_with_message(li, "Error getting canonicalization of %s: %s", path.string(), ec.message());
        return result;
    }
    fs::path Filesystem::canonical(const fs::path& path, ignore_errors_t) const
    {
        std::error_code ec;
        return this->canonical(path, ec);
    }
    fs::path Filesystem::current_path(LineInfo li) const
    {
        std::error_code ec;
        const auto result = this->current_path(ec);

        if (ec) Checks::exit_with_message(li, "Error getting current path: %s", ec.message());
        return result;
    }

    struct RealFilesystem final : Filesystem
    {
        virtual Expected<std::string> read_contents(const fs::path& file_path) const override
        {
            std::fstream file_stream(file_path, std::ios_base::in | std::ios_base::binary);
            if (file_stream.fail())
            {
                return std::make_error_code(std::errc::no_such_file_or_directory);
            }

            file_stream.seekg(0, file_stream.end);
            auto length = file_stream.tellg();
            file_stream.seekg(0, file_stream.beg);

            if (length == std::streampos(-1))
            {
                return std::make_error_code(std::errc::io_error);
            }

            std::string output;
            output.resize(static_cast<size_t>(length));
            file_stream.read(&output[0], length);
            file_stream.close();

            return output;
        }
        virtual Expected<std::vector<std::string>> read_lines(const fs::path& file_path) const override
        {
            std::fstream file_stream(file_path, std::ios_base::in | std::ios_base::binary);
            if (file_stream.fail())
            {
                return std::make_error_code(std::errc::no_such_file_or_directory);
            }

            std::vector<std::string> output;
            std::string line;
            while (std::getline(file_stream, line))
            {
                // Remove the trailing \r to accomodate Windows line endings.
                if ((!line.empty()) && (line.back() == '\r')) line.pop_back();

                output.push_back(line);
            }
            file_stream.close();

            return output;
        }
        virtual fs::path find_file_recursively_up(const fs::path& starting_dir,
                                                  const std::string& filename) const override
        {
            fs::path current_dir = starting_dir;
            if (exists(VCPKG_LINE_INFO, current_dir / filename))
            {
                return current_dir;
            }

            int counter = 10000;
            for (;;)
            {
                // This is a workaround for VS2015's experimental filesystem implementation
                if (!current_dir.has_relative_path())
                {
                    current_dir.clear();
                    return current_dir;
                }

                auto parent = current_dir.parent_path();
                if (parent == current_dir)
                {
                    current_dir.clear();
                    return current_dir;
                }

                current_dir = std::move(parent);

                const fs::path candidate = current_dir / filename;
                if (exists(VCPKG_LINE_INFO, candidate))
                {
                    return current_dir;
                }

                --counter;
                Checks::check_exit(VCPKG_LINE_INFO,
                                   counter > 0,
                                   "infinite loop encountered while trying to find_file_recursively_up()");
            }
        }

        virtual std::vector<fs::path> get_files_recursive(const fs::path& dir) const override
        {
            std::vector<fs::path> ret;

            std::error_code ec;
            fs::stdfs::recursive_directory_iterator b(dir, ec), e{};
            if (ec) return ret;
            for (; b != e; ++b)
            {
                ret.push_back(b->path());
            }

            return ret;
        }

        virtual std::vector<fs::path> get_files_non_recursive(const fs::path& dir) const override
        {
            std::vector<fs::path> ret;

            std::error_code ec;
            fs::stdfs::directory_iterator b(dir, ec), e{};
            if (ec) return ret;
            for (; b != e; ++b)
            {
                ret.push_back(b->path());
            }

            return ret;
        }

        virtual void write_lines(const fs::path& file_path,
                                 const std::vector<std::string>& lines,
                                 std::error_code& ec) override
        {
            std::fstream output(file_path, std::ios_base::out | std::ios_base::binary | std::ios_base::trunc);
            if (!output)
            {
                ec.assign(errno, std::generic_category());
                return;
            }
            for (const std::string& line : lines)
            {
                output << line << "\n";
                if (!output)
                {
                    output.close();
                    ec.assign(errno, std::generic_category());
                    return;
                }
            }
            output.close();
        }
        virtual void rename(const fs::path& oldpath, const fs::path& newpath, std::error_code& ec) override
        {
            fs::stdfs::rename(oldpath, newpath, ec);
        }
        virtual void rename_or_copy(const fs::path& oldpath,
                                    const fs::path& newpath,
                                    StringLiteral temp_suffix,
                                    std::error_code& ec) override
        {
            this->rename(oldpath, newpath, ec);
            Util::unused(temp_suffix);
#if !defined(_WIN32)
            if (ec)
            {
                auto dst = newpath;
                dst.replace_filename(dst.filename() + temp_suffix.c_str());

                int i_fd = open(oldpath.c_str(), O_RDONLY);
                if (i_fd == -1) return;

                int o_fd = creat(dst.c_str(), 0664);
                if (o_fd == -1)
                {
                    close(i_fd);
                    return;
                }

#if defined(__linux__)
                off_t bytes = 0;
                struct stat info = {0};
                fstat(i_fd, &info);
                auto written_bytes = sendfile(o_fd, i_fd, &bytes, info.st_size);
#elif defined(__APPLE__)
                auto written_bytes = fcopyfile(i_fd, o_fd, 0, COPYFILE_ALL);
#else
                ssize_t written_bytes = 0;
                {
                    constexpr std::size_t buffer_length = 4096;
                    auto buffer = std::make_unique<unsigned char[]>(buffer_length);
                    while (auto read_bytes = read(i_fd, buffer.get(), buffer_length))
                    {
                        if (read_bytes == -1)
                        {
                            written_bytes = -1;
                            break;
                        }
                        auto remaining = read_bytes;
                        while (remaining > 0)
                        {
                            auto read_result = write(o_fd, buffer.get(), remaining);
                            if (read_result == -1)
                            {
                                written_bytes = -1;
                                // break two loops
                                goto copy_failure;
                            }
                            remaining -= read_result;
                        }
                    }

                copy_failure:;
                }
#endif
                if (written_bytes == -1)
                {
                    ec.assign(errno, std::generic_category());
                    close(i_fd);
                    close(o_fd);

                    return;
                }

                close(i_fd);
                close(o_fd);

                this->rename(dst, newpath, ec);
                if (ec) return;
                this->remove(oldpath, ec);
            }
#endif
        }
        virtual bool remove(const fs::path& path, std::error_code& ec) override { return fs::stdfs::remove(path, ec); }
        virtual void remove_all(const fs::path& path, std::error_code& ec, fs::path& failure_point) override
        {
            /*
                does not use the std::experimental::filesystem call since this is
                quite a bit faster, and also supports symlinks
            */

            struct remove
            {
                struct ErrorInfo : Util::ResourceBase
                {
                    std::error_code ec;
                    fs::path failure_point;
                };
                /*
                    if `current_path` is a directory, first `remove`s all
                    elements of the directory, then removes current_path.

                    else if `current_path` exists, removes current_path

                    else does nothing
                */
                static void do_remove(const fs::path& current_path, ErrorInfo& err)
                {
                    std::error_code ec;
                    const auto path_status = Files::symlink_status(current_path, ec);
                    if (check_ec(ec, current_path, err)) return;
                    if (!fs::exists(path_status)) return;

                    const auto path_type = path_status.type();

                    if ((path_status.permissions() & fs::perms::owner_write) != fs::perms::owner_write)
                    {
                        set_writeable(current_path, ec);
                        if (check_ec(ec, current_path, err)) return;
                    }

                    if (path_type == fs::file_type::directory)
                    {
                        for (const auto& entry : fs::stdfs::directory_iterator(current_path))
                        {
                            do_remove(entry, err);
                            if (err.ec) return;
                        }
#if defined(_WIN32)
                        if (!RemoveDirectoryW(current_path.c_str()))
                        {
                            ec.assign(GetLastError(), std::system_category());
                        }
#else
                        if (rmdir(current_path.c_str()))
                        {
                            ec.assign(errno, std::system_category());
                        }
#endif
                    }
#if defined(_WIN32)
                    else if (path_type == fs::file_type::directory_symlink)
                    {
                        if (!RemoveDirectoryW(current_path.c_str()))
                        {
                            ec.assign(GetLastError(), std::system_category());
                        }
                    }
                    else
                    {
                        if (!DeleteFileW(current_path.c_str()))
                        {
                            ec.assign(GetLastError(), std::system_category());
                        }
                    }
#else
                    else
                    {
                        if (unlink(current_path.c_str()))
                        {
                            ec.assign(errno, std::system_category());
                        }
                    }
#endif

                    check_ec(ec, current_path, err);
                }

                static bool check_ec(const std::error_code& ec, const fs::path& current_path, ErrorInfo& err)
                {
                    if (ec)
                    {
                        err.ec = ec;
                        err.failure_point = current_path;

                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
            };

            /*
                we need to do backoff on the removal of the top level directory,
                so we can only delete the directory after all the
                lower levels have been deleted.
            */

            remove::ErrorInfo err;
            for (int backoff = 0; backoff < 5; ++backoff)
            {
                if (backoff)
                {
                    using namespace std::chrono_literals;
                    auto backoff_time = 100ms * backoff;
                    std::this_thread::sleep_for(backoff_time);
                }

                remove::do_remove(path, err);
                if (!err.ec)
                {
                    break;
                }
            }

            ec = std::move(err.ec);
            failure_point = std::move(err.failure_point);
        }
        virtual bool is_directory(const fs::path& path) const override { return fs::stdfs::is_directory(path); }
        virtual bool is_regular_file(const fs::path& path) const override { return fs::stdfs::is_regular_file(path); }
        virtual bool is_empty(const fs::path& path) const override { return fs::stdfs::is_empty(path); }
        virtual bool create_directory(const fs::path& path, std::error_code& ec) override
        {
            return fs::stdfs::create_directory(path, ec);
        }
        virtual bool create_directories(const fs::path& path, std::error_code& ec) override
        {
            return fs::stdfs::create_directories(path, ec);
        }
        virtual void copy(const fs::path& oldpath, const fs::path& newpath, fs::copy_options opts) override
        {
            fs::stdfs::copy(oldpath, newpath, opts);
        }
        virtual bool copy_file(const fs::path& oldpath,
                               const fs::path& newpath,
                               fs::copy_options opts,
                               std::error_code& ec) override
        {
            return fs::stdfs::copy_file(oldpath, newpath, opts, ec);
        }
        virtual void copy_symlink(const fs::path& oldpath, const fs::path& newpath, std::error_code& ec) override
        {
            return fs::stdfs::copy_symlink(oldpath, newpath, ec);
        }

        virtual fs::file_status status(const fs::path& path, std::error_code& ec) const override
        {
            return Files::status(path, ec);
        }
        virtual fs::file_status symlink_status(const fs::path& path, std::error_code& ec) const override
        {
            return Files::symlink_status(path, ec);
        }
        virtual void write_contents(const fs::path& file_path, const std::string& data, std::error_code& ec) override
        {
            ec.clear();

            FILE* f = nullptr;
#if defined(_WIN32)
            auto err = _wfopen_s(&f, file_path.native().c_str(), L"wb");
#else
            f = fopen(file_path.native().c_str(), "wb");
            int err = f != nullptr ? 0 : 1;
#endif
            if (err != 0)
            {
                ec.assign(err, std::system_category());
                return;
            }

            if (f != nullptr)
            {
                auto count = fwrite(data.data(), sizeof(data[0]), data.size(), f);
                fclose(f);

                if (count != data.size())
                {
                    ec = std::make_error_code(std::errc::no_space_on_device);
                }
            }
        }

        virtual fs::path absolute(const fs::path& path, std::error_code& ec) const override
        {
#if VCPKG_USE_STD_FILESYSTEM 
            return fs::stdfs::absolute(path, ec);
#else // ^^^ VCPKG_USE_STD_FILESYSTEM  / !VCPKG_USE_STD_FILESYSTEM  vvv
#if _WIN32
            // absolute was called system_complete in experimental filesystem
            return fs::stdfs::system_complete(path, ec);
#else // ^^^ _WIN32 / !_WIN32 vvv
            if (path.is_absolute()) {
                auto current_path = this->current_path(ec);
                if (ec) return fs::path();
                return std::move(current_path) / path;
            } else {
                return path;
            }
#endif
#endif
        }

        virtual fs::path canonical(const fs::path& path, std::error_code& ec) const override
        {
            return fs::stdfs::canonical(path, ec);
        }

        virtual fs::path current_path(std::error_code& ec) const override
        {
            return fs::stdfs::current_path(ec);
        }

        virtual std::vector<fs::path> find_from_PATH(const std::string& name) const override
        {
#if defined(_WIN32)
            static constexpr StringLiteral EXTS[] = {".cmd", ".exe", ".bat"};
            auto paths = Strings::split(System::get_environment_variable("PATH").value_or_exit(VCPKG_LINE_INFO), ";");
#else
            static constexpr StringLiteral EXTS[] = {""};
            auto paths = Strings::split(System::get_environment_variable("PATH").value_or_exit(VCPKG_LINE_INFO), ":");
#endif

            std::vector<fs::path> ret;
            std::error_code ec;
            for (auto&& path : paths)
            {
                auto base = path + "/" + name;
                for (auto&& ext : EXTS)
                {
                    auto p = fs::u8path(base + ext.c_str());
                    if (Util::find(ret, p) == ret.end() && this->exists(p, ec))
                    {
                        ret.push_back(p);
                        Debug::print("Found path: ", p.u8string(), '\n');
                    }
                }
            }

            return ret;
        }
    };

    Filesystem& get_real_filesystem()
    {
        static RealFilesystem real_fs;
        return real_fs;
    }

    bool has_invalid_chars_for_filesystem(const std::string& s)
    {
        return std::regex_search(s, FILESYSTEM_INVALID_CHARACTERS_REGEX);
    }

    void print_paths(const std::vector<fs::path>& paths)
    {
        std::string message = "\n";
        for (const fs::path& p : paths)
        {
            Strings::append(message, "    ", p.generic_string(), '\n');
        }
        message.push_back('\n');
        System::print2(message);
    }
}
