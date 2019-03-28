#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>

#if defined(__linux__)
#include <fcntl.h>
#include <sys/sendfile.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#endif

namespace vcpkg::Files
{
    static const std::regex FILESYSTEM_INVALID_CHARACTERS_REGEX = std::regex(R"([\/:*?"<>|])");

    void Filesystem::write_contents(const fs::path& file_path, const std::string& data)
    {
        std::error_code ec;
        write_contents(file_path, data, ec);
        Checks::check_exit(
            VCPKG_LINE_INFO, !ec, "error while writing file: %s: %s", file_path.u8string(), ec.message());
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

            return std::move(output);
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

            return std::move(output);
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

        virtual void write_lines(const fs::path& file_path, const std::vector<std::string>& lines) override
        {
            std::fstream output(file_path, std::ios_base::out | std::ios_base::binary | std::ios_base::trunc);
            for (const std::string& line : lines)
            {
                output << line << "\n";
            }
            output.close();
        }

        virtual void rename(const fs::path& oldpath, const fs::path& newpath, std::error_code& ec) override
        {
            fs::stdfs::rename(oldpath, newpath, ec);
        }
        virtual void rename(const fs::path& oldpath, const fs::path& newpath) override
        {
            fs::stdfs::rename(oldpath, newpath);
        }
        virtual void rename_or_copy(const fs::path& oldpath,
                                    const fs::path& newpath,
                                    StringLiteral temp_suffix,
                                    std::error_code& ec) override
        {
            this->rename(oldpath, newpath, ec);
#if defined(__linux__)
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

                off_t bytes = 0;
                struct stat info = {0};
                fstat(i_fd, &info);
                auto written_bytes = sendfile(o_fd, i_fd, &bytes, info.st_size);
                close(i_fd);
                close(o_fd);
                if (written_bytes == -1) return;

                this->rename(dst, newpath, ec);
                if (ec) return;
                this->remove(oldpath, ec);
            }
#endif
        }
        virtual bool remove(const fs::path& path) override { return fs::stdfs::remove(path); }
        virtual bool remove(const fs::path& path, std::error_code& ec) override { return fs::stdfs::remove(path, ec); }
        virtual std::uintmax_t remove_all(const fs::path& path, std::error_code& ec) override
        {
            // Working around the currently buggy remove_all()
            std::uintmax_t out = fs::stdfs::remove_all(path, ec);

            for (int i = 0; i < 5 && this->exists(path); i++)
            {
                using namespace std::chrono_literals;
                std::this_thread::sleep_for(i * 100ms);
                out += fs::stdfs::remove_all(path, ec);
            }

            if (this->exists(path))
            {
                System::println(System::Color::warning,
                                "Some files in %s were unable to be removed. Close any editors operating in this "
                                "directory and retry.",
                                path.string());
            }

            return out;
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
            return fs::stdfs::status(path, ec);
        }
        virtual fs::file_status symlink_status(const fs::path& path, std::error_code& ec) const override
        {
            return fs::stdfs::symlink_status(path, ec);
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
                        Debug::println("Found path: %s", p.u8string());
                    }
                }
            }

            return ret;
#else
            const std::string cmd = Strings::format("which %s", name);
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
        System::println();
        for (const fs::path& p : paths)
        {
            System::println("    %s", p.generic_string());
        }
        System::println();
    }
}
