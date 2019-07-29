#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>
#include <vcpkg/base/work_queue.h>

#if defined(__linux__) || defined(__APPLE__)
#include <fcntl.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#endif
#if defined(__linux__)
#include <sys/sendfile.h>
#elif defined(__APPLE__)
#include <copyfile.h>
#endif

namespace fs::detail
{
    file_status symlink_status_t::operator()(const path& p, std::error_code& ec) const noexcept
    {
#if defined(_WIN32)
        static_cast<void>(ec);

        WIN32_FILE_ATTRIBUTE_DATA file_attributes;
        file_type ft = file_type::unknown;
        perms permissions = perms::unknown;
        if (!GetFileAttributesExW(p.c_str(), GetFileExInfoStandard, &file_attributes))
        {
            ft = file_type::not_found;
        }
        else if (file_attributes.dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT)
        {
            // check for reparse point -- if yes, then symlink
            ft = file_type::symlink;
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

        return file_status(ft, permissions);

#else
        return stdfs::symlink_status(p, ec);
#endif
    }

    file_status symlink_status_t::operator()(vcpkg::LineInfo li, const path& p) const noexcept
    {
        std::error_code ec;
        auto result = symlink_status(p, ec);
        if (ec) vcpkg::Checks::exit_with_message(li, "error getting status of path %s: %s", p.string(), ec.message());

        return result;
    }
}

namespace vcpkg::Files
{
    static const std::regex FILESYSTEM_INVALID_CHARACTERS_REGEX = std::regex(R"([\/:*?"<>|])");

    namespace {
        // does _not_ follow symlinks
        void set_writeable(const fs::path& path, std::error_code& ec) noexcept {
#if defined(_WIN32)
            auto const file_name = path.c_str();
            WIN32_FILE_ATTRIBUTE_DATA attributes;
            if (!GetFileAttributesExW(file_name, GetFileExInfoStandard, &attributes)) {
                ec.assign(GetLastError(), std::system_category());
                return;
            }

            auto dw_attributes = attributes.dwFileAttributes;
            dw_attributes &= ~FILE_ATTRIBUTE_READONLY;
            if (!SetFileAttributesW(file_name, dw_attributes)) {
                ec.assign(GetLastError(), std::system_category());
            }
#else
            struct stat s;
            if (lstat(path.c_str(), &s)) {
                ec.assign(errno, std::system_category());
                return;
            }

            auto mode = s.st_mode;
            // if the file is a symlink, perms don't matter
            if (!(mode & S_IFLNK)) {
                mode |= S_IWUSR;
                if (chmod(path.c_str(), mode)) {
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

    void Filesystem::write_lines(const fs::path& path, const std::vector<std::string>& lines, LineInfo linfo)
    {
        std::error_code ec;
        this->write_lines(path, lines, ec);
        if (ec) Checks::exit_with_message(linfo, "error writing lines: %s: %s", path.u8string(), ec.message());
    }

    std::uintmax_t Filesystem::remove_all(const fs::path& path, LineInfo li)
    {
        std::error_code ec;
        fs::path failure_point;

        const auto result = this->remove_all(path, ec, failure_point);

        if (ec)
        {
            Checks::exit_with_message(li,
                                      "Failure to remove_all(%s) due to file %s: %s",
                                      path.string(),
                                      failure_point.string(),
                                      ec.message());
        }

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
                output.push_back(line);
            }
            file_stream.close();

            return output;
        }
        virtual fs::path find_file_recursively_up(const fs::path& starting_dir,
                                                  const std::string& filename) const override
        {
            fs::path current_dir = starting_dir;
            if (exists(current_dir / filename))
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
                if (exists(candidate))
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
#if defined(__linux__) || defined(__APPLE__)
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
        virtual std::uintmax_t remove_all(const fs::path& path, std::error_code& ec, fs::path& failure_point) override
        {
            /*
                does not use the std::filesystem call since it is buggy, and can
                have spurious errors before VS 2017 update 6, and on later versions
                (as well as on macOS and Linux), this is just as fast and will have
                fewer spurious errors due to locks.
            */

            /*
                `remove` doesn't actually remove anything -- it simply moves the
                files into a parent directory (which ends up being at `path`),
                and then inserts `actually_remove{current_path}` into the work
                queue.
            */
            struct remove
            {
                struct tld
                {
                    const fs::path& tmp_directory;
                    std::uint64_t index;

                    std::atomic<std::uintmax_t>& files_deleted;

                    std::mutex& ec_mutex;
                    std::error_code& ec;
                    fs::path& failure_point;
                };

                struct actually_remove;
                using queue = WorkQueue<actually_remove, tld>;

                /*
                    if `current_path` is a directory, first `remove`s all
                    elements of the directory, then calls remove.

                    else, just calls remove.
                */
                struct actually_remove
                {
                    fs::path current_path;

                    void operator()(tld& info, const queue& queue) const
                    {
                        std::error_code ec;
                        const auto path_type = fs::symlink_status(current_path, ec).type();

                        if (check_ec(ec, info, queue, current_path)) return;

                        if (path_type == fs::file_type::directory)
                        {
                            for (const auto& entry : fs::stdfs::directory_iterator(current_path))
                            {
                                remove{}(entry, info, queue);
                            }
                        }

                        set_writeable(current_path, ec);
                        if (check_ec(ec, info, queue, current_path)) return;

                        if (fs::stdfs::remove(current_path, ec))
                        {
                            info.files_deleted.fetch_add(1, std::memory_order_relaxed);
                        }
                        else
                        {
                            check_ec(ec, info, queue, current_path);
                        }
                    }
                };

                static bool check_ec(const std::error_code& ec,
                                     tld& info,
                                     const queue& queue,
                                     const fs::path& failure_point)
                {
                    if (ec)
                    {
                        queue.terminate();

                        auto lck = std::unique_lock<std::mutex>(info.ec_mutex);
                        if (!info.ec)
                        {
                            info.ec = ec;
                            info.failure_point = failure_point;
                        }

                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }

                void operator()(const fs::path& current_path, tld& info, const queue& queue) const
                {
                    std::error_code ec;

                    const auto tmp_name = Strings::b32_encode(info.index++);
                    const auto tmp_path = info.tmp_directory / tmp_name;

                    fs::stdfs::rename(current_path, tmp_path, ec);
                    if (check_ec(ec, info, queue, current_path)) return;

                    queue.enqueue_action(actually_remove{std::move(tmp_path)});
                }
            };

            const auto path_type = fs::symlink_status(path, ec).type();

            std::atomic<std::uintmax_t> files_deleted{0};

            if (path_type == fs::file_type::directory)
            {
                std::uint64_t index = 0;
                std::mutex ec_mutex;

                auto const tld_gen = [&] {
                    index += static_cast<std::uint64_t>(1) << 32;
                    return remove::tld{path, index, files_deleted, ec_mutex, ec, failure_point};
                };

                remove::queue queue{VCPKG_LINE_INFO, 4, tld_gen};

                // note: we don't actually start the queue running until the
                // `join()`. This allows us to rename all the top-level files in
                // peace, so that we don't get collisions.
                auto main_tld = tld_gen();
                for (const auto& entry : fs::stdfs::directory_iterator(path))
                {
                    remove{}(entry, main_tld, queue);
                }

                queue.join(VCPKG_LINE_INFO);
            }

            /*
                we need to do backoff on the removal of the top level directory,
                since we need to place all moved files into that top level
                directory, and so we can only delete the directory after all the
                lower levels have been deleted.
            */
            for (int backoff = 0; backoff < 5; ++backoff)
            {
                if (backoff)
                {
                    using namespace std::chrono_literals;
                    auto backoff_time = 100ms * backoff;
                    std::this_thread::sleep_for(backoff_time);
                }

                if (fs::stdfs::remove(path, ec))
                {
                    files_deleted.fetch_add(1, std::memory_order_relaxed);
                    break;
                }
            }

            return files_deleted;
        }
        virtual bool exists(const fs::path& path) const override { return fs::stdfs::exists(path); }
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
            return fs::status(path, ec);
        }
        virtual fs::file_status symlink_status(const fs::path& path, std::error_code& ec) const override
        {
            return fs::symlink_status(path, ec);
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

        virtual std::vector<fs::path> find_from_PATH(const std::string& name) const override
        {
#if defined(_WIN32)
            static constexpr StringLiteral EXTS[] = {".cmd", ".exe", ".bat"};
            auto paths = Strings::split(System::get_environment_variable("PATH").value_or_exit(VCPKG_LINE_INFO), ";");

            std::vector<fs::path> ret;
            for (auto&& path : paths)
            {
                auto base = path + "/" + name;
                for (auto&& ext : EXTS)
                {
                    auto p = fs::u8path(base + ext.c_str());
                    if (Util::find(ret, p) == ret.end() && this->exists(p))
                    {
                        ret.push_back(p);
                        Debug::print("Found path: ", p.u8string(), '\n');
                    }
                }
            }

            return ret;
#else
            const std::string cmd = Strings::concat("which ", name);
            auto out = System::cmd_execute_and_capture_output(cmd);
            if (out.exit_code != 0)
            {
                return {};
            }

            return Util::fmap(Strings::split(out.output, "\n"), [](auto&& s) { return fs::path(s); });
#endif
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
