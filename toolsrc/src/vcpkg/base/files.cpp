#include <vcpkg/base/files.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#if defined(_WIN32)
#include <vcpkg/base/system_headers.h>
#else // ^^^ _WIN32 // !_WIN32 vvv
#include <fcntl.h>

#include <sys/file.h>
#include <sys/stat.h>
#endif // _WIN32

#if defined(__linux__)
#include <sys/sendfile.h>
#elif defined(__APPLE__)
#include <copyfile.h>
#endif // ^^^ defined(__APPLE__)

#include <algorithm>
#include <list>
#include <string>

namespace
{
    struct NativeStringView
    {
        const fs::path::value_type* first;
        const fs::path::value_type* last;
        NativeStringView() = default;
        NativeStringView(const fs::path::value_type* first, const fs::path::value_type* last) : first(first), last(last)
        {
        }
        bool empty() const { return first == last; }
        bool is_dot() const { return (last - first) == 1 && *first == '.'; }
        bool is_dot_dot() const { return (last - first) == 2 && *first == '.' && *(first + 1) == '.'; }
    };
}

#if defined(_WIN32)
namespace
{
    template<size_t N>
    bool wide_starts_with(const std::wstring& haystack, const wchar_t (&needle)[N]) noexcept
    {
        const size_t without_null = N - 1;
        return haystack.size() >= without_null && std::equal(needle, needle + without_null, haystack.begin());
    }

    bool starts_with_drive_letter(std::wstring::const_iterator first, const std::wstring::const_iterator last) noexcept
    {
        if (last - first < 2)
        {
            return false;
        }

        if (!(first[0] >= L'a' && first[0] <= L'z') && !(first[0] >= L'A' && first[0] <= L'Z'))
        {
            return false;
        }

        if (first[1] != L':')
        {
            return false;
        }

        return true;
    }

    struct FindFirstOp
    {
        HANDLE h_find = INVALID_HANDLE_VALUE;
        WIN32_FIND_DATAW find_data;

        unsigned long find_first(const wchar_t* const path) noexcept
        {
            assert(h_find == INVALID_HANDLE_VALUE);
            h_find = FindFirstFileW(path, &find_data);
            if (h_find == INVALID_HANDLE_VALUE)
            {
                return GetLastError();
            }

            return ERROR_SUCCESS;
        }

        FindFirstOp() = default;
        FindFirstOp(const FindFirstOp&) = delete;
        FindFirstOp& operator=(const FindFirstOp&) = delete;

        ~FindFirstOp()
        {
            if (h_find != INVALID_HANDLE_VALUE)
            {
                (void)FindClose(h_find);
            }
        }
    };
} // unnamed namespace
#endif // _WIN32

fs::path fs::u8path(vcpkg::StringView s)
{
#if defined(_WIN32)
    return fs::path(vcpkg::Strings::to_utf16(s));
#else
    return fs::path(s.begin(), s.end());
#endif
}

std::string fs::u8string(const fs::path& p)
{
#if defined(_WIN32)
    return vcpkg::Strings::to_utf8(p.native());
#else
    return p.native();
#endif
}
std::string fs::generic_u8string(const fs::path& p)
{
#if defined(_WIN32)
    return vcpkg::Strings::to_utf8(p.generic_wstring());
#else
    return p.generic_string();
#endif
}

fs::path fs::lexically_normal(const fs::path& p)
{
    // copied from microsoft/STL, stl/inc/filesystem:lexically_normal()
    // relicensed under MIT for the vcpkg repository.

    // N4810 29.11.7.1 [fs.path.generic]/6:
    // "Normalization of a generic format pathname means:"

    // "1. If the path is empty, stop."
    if (p.empty())
    {
        return {};
    }

    // "2. Replace each slash character in the root-name with a preferred-separator."
    const auto first = p.native().data();
    const auto last = first + p.native().size();
    const auto root_name_end = first + p.root_name().native().size();

    fs::path::string_type normalized(first, root_name_end);

#if defined(_WIN32)
    std::replace(normalized.begin(), normalized.end(), L'/', L'\\');
#endif

    // "3. Replace each directory-separator with a preferred-separator.
    // [ Note: The generic pathname grammar (29.11.7.1) defines directory-separator
    // as one or more slashes and preferred-separators. -end note ]"
    std::list<NativeStringView> lst; // Empty string_view means directory-separator
                                     // that will be normalized to a preferred-separator.
                                     // Non-empty string_view means filename.
    for (auto next = root_name_end; next != last;)
    {
        if (is_slash(*next))
        {
            if (lst.empty() || !lst.back().empty())
            {
                // collapse one or more slashes and preferred-separators to one empty wstring_view
                lst.emplace_back();
            }

            ++next;
        }
        else
        {
            const auto filename_end = std::find_if(next + 1, last, is_slash);
            lst.emplace_back(next, filename_end);
            next = filename_end;
        }
    }

    // "4. Remove each dot filename and any immediately following directory-separator."
    for (auto next = lst.begin(); next != lst.end();)
    {
        if (next->is_dot())
        {
            next = lst.erase(next); // erase dot filename

            if (next != lst.end())
            {
                next = lst.erase(next); // erase immediately following directory-separator
            }
        }
        else
        {
            ++next;
        }
    }

    // "5. As long as any appear, remove a non-dot-dot filename immediately followed by a
    // directory-separator and a dot-dot filename, along with any immediately following directory-separator."
    for (auto next = lst.begin(); next != lst.end();)
    {
        auto prev = next;

        // If we aren't going to erase, keep advancing.
        // If we're going to erase, next now points past the dot-dot filename.
        ++next;

        if (prev->is_dot_dot() && prev != lst.begin() && --prev != lst.begin() && !(--prev)->is_dot_dot())
        {
            if (next != lst.end())
            { // dot-dot filename has an immediately following directory-separator
                ++next;
            }

            lst.erase(prev, next); // next remains valid
        }
    }

    // "6. If there is a root-directory, remove all dot-dot filenames
    // and any directory-separators immediately following them.
    // [ Note: These dot-dot filenames attempt to refer to nonexistent parent directories. -end note ]"
    if (!lst.empty() && lst.front().empty())
    { // we have a root-directory
        for (auto next = lst.begin(); next != lst.end();)
        {
            if (next->is_dot_dot())
            {
                next = lst.erase(next); // erase dot-dot filename

                if (next != lst.end())
                {
                    next = lst.erase(next); // erase immediately following directory-separator
                }
            }
            else
            {
                ++next;
            }
        }
    }

    // "7. If the last filename is dot-dot, remove any trailing directory-separator."
    if (lst.size() >= 2 && lst.back().empty() && std::prev(lst.end(), 2)->is_dot_dot())
    {
        lst.pop_back();
    }

    // Build up normalized by flattening lst.
    for (const auto& elem : lst)
    {
        if (elem.empty())
        {
            normalized += fs::path::preferred_separator;
        }
        else
        {
            normalized.append(elem.first, elem.last);
        }
    }

    // "8. If the path is empty, add a dot."
    if (normalized.empty())
    {
        normalized.push_back('.');
    }

    // "The result of normalization is a path in normal form, which is said to be normalized."
    return std::move(normalized);
}

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
            ec.clear();
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
            else if (ft != file_type::none)
            {
                permissions = perms::all;
            }

            return fs::file_status(ft, permissions);

#else  // ^^^ defined(_WIN32) // !defined(_WIN32) vvv
            auto result = follow_symlinks ? fs::stdfs::status(p, ec) : fs::stdfs::symlink_status(p, ec);
            // libstdc++ doesn't correctly not-set ec on nonexistent paths
            if (ec.value() == ENOENT || ec.value() == ENOTDIR)
            {
                ec.clear();
                return fs::file_status(file_type::not_found, perms::unknown);
            }
            return fs::file_status(result.type(), result.permissions());
#endif // ^^^ !defined(_WIN32)
        }

        fs::file_status status(const fs::path& p, std::error_code& ec) noexcept
        {
            return status_implementation(true, p, ec);
        }
        fs::file_status symlink_status(const fs::path& p, std::error_code& ec) noexcept
        {
            return status_implementation(false, p, ec);
        }

#if defined(_WIN32) && !VCPKG_USE_STD_FILESYSTEM
        fs::path read_symlink_implementation(const fs::path& oldpath, std::error_code& ec)
        {
            ec.clear();
            auto handle = CreateFileW(oldpath.c_str(),
                                      0, // open just the metadata
                                      FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
                                      nullptr /* no security attributes */,
                                      OPEN_EXISTING,
                                      FILE_ATTRIBUTE_NORMAL,
                                      nullptr /* no template file */);
            if (handle == INVALID_HANDLE_VALUE)
            {
                ec.assign(GetLastError(), std::system_category());
                return oldpath;
            }
            fs::path target;
            const DWORD maxsize = 32768;
            const std::unique_ptr<wchar_t[]> buffer(new wchar_t[maxsize]);
            const auto rc = GetFinalPathNameByHandleW(handle, buffer.get(), maxsize, 0);
            if (rc > 0 && rc < maxsize)
            {
                target = buffer.get();
            }
            else
            {
                ec.assign(GetLastError(), std::system_category());
            }
            CloseHandle(handle);
            return target;
        }
#endif // ^^^ defined(_WIN32) && !VCPKG_USE_STD_FILESYSTEM

        void copy_symlink_implementation(const fs::path& oldpath, const fs::path& newpath, std::error_code& ec)
        {
#if defined(_WIN32) && !VCPKG_USE_STD_FILESYSTEM
            const auto target = read_symlink_implementation(oldpath, ec);
            if (ec) return;

            const DWORD flags =
#if defined(SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE)
                SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE;
#else
                0;
#endif
            if (!CreateSymbolicLinkW(newpath.c_str(), target.c_str(), flags))
            {
                const auto err = GetLastError();
                ec.assign(err, std::system_category());
                return;
            }
            ec.clear();
            return;
#else  // ^^^ defined(_WIN32) && !VCPKG_USE_STD_FILESYSTEM // !defined(_WIN32) || VCPKG_USE_STD_FILESYSTEM vvv
            return fs::stdfs::copy_symlink(oldpath, newpath, ec);
#endif // ^^^ !defined(_WIN32) || VCPKG_USE_STD_FILESYSTEM
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
#else  // ^^^ defined(_WIN32) // !defined(_WIN32) vvv
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
#endif // ^^^ !defined(_WIN32)
        }
    }

    std::string Filesystem::read_contents(const fs::path& path, LineInfo linfo) const
    {
        auto maybe_contents = this->read_contents(path);
        if (auto p = maybe_contents.get())
            return std::move(*p);
        else
            Checks::exit_with_message(
                linfo, "error reading file: %s: %s", fs::u8string(path), maybe_contents.error().message());
    }
    void Filesystem::write_contents(const fs::path& path, const std::string& data, LineInfo linfo)
    {
        std::error_code ec;
        this->write_contents(path, data, ec);
        if (ec) Checks::exit_with_message(linfo, "error writing file: %s: %s", fs::u8string(path), ec.message());
    }
    void Filesystem::rename(const fs::path& oldpath, const fs::path& newpath, LineInfo linfo)
    {
        std::error_code ec;
        this->rename(oldpath, newpath, ec);
        if (ec)
            Checks::exit_with_message(
                linfo, "error renaming file: %s: %s: %s", fs::u8string(oldpath), fs::u8string(newpath), ec.message());
    }

    bool Filesystem::remove(const fs::path& path, LineInfo linfo)
    {
        std::error_code ec;
        auto r = this->remove(path, ec);
        if (ec) Checks::exit_with_message(linfo, "error removing file: %s: %s", fs::u8string(path), ec.message());
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
        if (ec)
            Checks::exit_with_message(li, "error checking existence of file %s: %s", fs::u8string(path), ec.message());
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

    bool Filesystem::create_directory(const fs::path& path, LineInfo li)
    {
        std::error_code ec;
        bool result = this->create_directory(path, ec);
        if (ec)
        {
            vcpkg::Checks::exit_with_message(li, "error creating directory %s", fs::u8string(path), ec.message());
        }

        return result;
    }

    bool Filesystem::create_directories(const fs::path& path, ignore_errors_t)
    {
        std::error_code ec;
        return this->create_directories(path, ec);
    }

    bool Filesystem::create_directories(const fs::path& path, LineInfo li)
    {
        std::error_code ec;
        bool result = this->create_directories(path, ec);
        if (ec)
        {
            vcpkg::Checks::exit_with_message(li, "error creating directories %s", fs::u8string(path), ec.message());
        }

        return result;
    }

    void Filesystem::copy_file(const fs::path& oldpath, const fs::path& newpath, fs::copy_options opts, LineInfo li)
    {
        std::error_code ec;
        this->copy_file(oldpath, newpath, opts, ec);
        if (ec)
            vcpkg::Checks::exit_with_message(
                li, "error copying file from %s to %s: %s", fs::u8string(oldpath), fs::u8string(newpath), ec.message());
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
        if (ec) Checks::exit_with_message(linfo, "error writing lines: %s: %s", fs::u8string(path), ec.message());
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

    void Filesystem::remove_all_inside(const fs::path& path, LineInfo li)
    {
        std::error_code ec;
        fs::path failure_point;

        this->remove_all_inside(path, ec, failure_point);

        if (ec)
        {
            Checks::exit_with_message(li,
                                      "Failure to remove_all_inside(%s) due to file %s: %s",
                                      path.string(),
                                      failure_point.string(),
                                      ec.message());
        }
    }

    void Filesystem::remove_all_inside(const fs::path& path, ignore_errors_t)
    {
        std::error_code ec;
        fs::path failure_point;

        this->remove_all_inside(path, ec, failure_point);
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
    void Filesystem::current_path(const fs::path& path, LineInfo li)
    {
        std::error_code ec;
        this->current_path(path, ec);
        if (ec) Checks::exit_with_message(li, "Error setting current path: %s", ec.message());
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
                Debug::print("Missing path: ", fs::u8string(file_path), '\n');
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
        virtual fs::path find_file_recursively_up(const fs::path& starting_dir, const fs::path& filename) const override
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
            (void)temp_suffix;
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
#else  // ^^^ defined(__APPLE__) // !(defined(__APPLE__) || defined(__linux__)) vvv
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
#endif // ^^^ !(defined(__APPLE__) || defined(__linux__))
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
#endif // ^^^ !defined(_WIN32)
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
#else  // ^^^ defined(_WIN32) // !defined(_WIN32) vvv
                        if (rmdir(current_path.c_str()))
                        {
                            ec.assign(errno, std::system_category());
                        }
#endif // ^^^ !defined(_WIN32)
                    }
#if VCPKG_USE_STD_FILESYSTEM
                    else
                    {
                        fs::stdfs::remove(current_path, ec);
                        if (check_ec(ec, current_path, err)) return;
                    }
#else // ^^^  VCPKG_USE_STD_FILESYSTEM // !VCPKG_USE_STD_FILESYSTEM vvv
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
#else  // ^^^ defined(_WIN32) // !defined(_WIN32) vvv
                    else
                    {
                        if (unlink(current_path.c_str()))
                        {
                            ec.assign(errno, std::system_category());
                        }
                    }
#endif // ^^^ !defined(_WIN32)
#endif // ^^^ !VCPKG_USE_STD_FILESYSTEM

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

        virtual void remove_all_inside(const fs::path& path, std::error_code& ec, fs::path& failure_point) override
        {
            fs::directory_iterator last{};
            fs::directory_iterator first(path, ec);
            if (ec)
            {
                failure_point = path;
                return;
            }

            for (;;)
            {
                if (first == last)
                {
                    return;
                }

                auto stats = first->status(ec);
                if (ec)
                {
                    break;
                }

                auto& thisPath = first->path();
                if (stats.type() == fs::stdfs::file_type::directory)
                {
                    this->remove_all(thisPath, ec, failure_point);
                    if (ec)
                    {
                        return; // keep inner failure_point
                    }
                }
                else
                {
                    this->remove(thisPath, ec);
                    if (ec)
                    {
                        break;
                    }
                }

                first.increment(ec);
                if (ec)
                {
                    break;
                }
            }

            failure_point = first->path();
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
            return Files::copy_symlink_implementation(oldpath, newpath, ec);
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
#else  // ^^^ defined(_WIN32) // !defined(_WIN32) vvv
            f = fopen(file_path.native().c_str(), "wb");
            int err = f != nullptr ? 0 : 1;
#endif // ^^^ !defined(_WIN32)
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
#else // ^^^ VCPKG_USE_STD_FILESYSTEM  /  !VCPKG_USE_STD_FILESYSTEM  vvv
#if defined(_WIN32)
            // absolute was called system_complete in experimental filesystem
            return fs::stdfs::system_complete(path, ec);
#else  // ^^^ defined(_WIN32) / !defined(_WIN32) vvv
            if (path.is_absolute())
            {
                return path;
            }
            else
            {
                auto current_path = this->current_path(ec);
                if (ec) return fs::path();
                return std::move(current_path) / path;
            }
#endif // ^^^ !defined(_WIN32)
#endif // ^^^ !VCPKG_USE_STD_FILESYSTEM
        }

        virtual fs::path canonical(const fs::path& path, std::error_code& ec) const override
        {
            return fs::stdfs::canonical(path, ec);
        }

        virtual fs::path current_path(std::error_code& ec) const override { return fs::stdfs::current_path(ec); }
        virtual void current_path(const fs::path& path, std::error_code& ec) override
        {
            fs::stdfs::current_path(path, ec);
        }

        struct TakeExclusiveFileLockHelper
        {
            fs::SystemHandle& res;
            const fs::path::string_type& native;
            TakeExclusiveFileLockHelper(fs::SystemHandle& res, const fs::path::string_type& native)
                : res(res), native(native)
            {
            }

#if defined(WIN32)
            void assign_busy_error(std::error_code& ec) { ec.assign(ERROR_BUSY, std::system_category()); }

            bool operator()(std::error_code& ec)
            {
                ec.clear();
                auto handle = CreateFileW(native.c_str(),
                                          GENERIC_READ,
                                          0 /* no sharing */,
                                          nullptr /* no security attributes */,
                                          OPEN_ALWAYS,
                                          FILE_ATTRIBUTE_NORMAL,
                                          nullptr /* no template file */);
                if (handle == INVALID_HANDLE_VALUE)
                {
                    const auto err = GetLastError();
                    if (err != ERROR_SHARING_VIOLATION)
                    {
                        ec.assign(err, std::system_category());
                    }
                    return false;
                }

                res.system_handle = reinterpret_cast<intptr_t>(handle);
                return true;
            }
#else // ^^^ WIN32 / !WIN32 vvv
            int fd = -1;

            void assign_busy_error(std::error_code& ec) { ec.assign(EBUSY, std::generic_category()); }

            bool operator()(std::error_code& ec)
            {
                ec.clear();
                if (fd == -1)
                {
                    fd = ::open(native.c_str(), 0);
                    if (fd < 0)
                    {
                        ec.assign(errno, std::generic_category());
                        return false;
                    }
                }

                if (::flock(fd, LOCK_EX | LOCK_NB) != 0)
                {
                    if (errno != EWOULDBLOCK)
                    {
                        ec.assign(errno, std::generic_category());
                    }
                    return false;
                }

                res.system_handle = fd;
                fd = -1;
                return true;
            };

            ~TakeExclusiveFileLockHelper()
            {
                if (fd != -1)
                {
                    ::close(fd);
                }
            }
#endif
        };

        virtual fs::SystemHandle take_exclusive_file_lock(const fs::path& path, std::error_code& ec) override
        {
            fs::SystemHandle res;
            TakeExclusiveFileLockHelper helper(res, path.native());

            if (helper(ec) || ec)
            {
                return res;
            }

            System::printf("Waiting to take filesystem lock on %s...\n", fs::u8string(path));
            const auto wait = std::chrono::milliseconds(1000);
            for (;;)
            {
                std::this_thread::sleep_for(wait);
                if (helper(ec) || ec)
                {
                    return res;
                }
            }
        }

        virtual fs::SystemHandle try_take_exclusive_file_lock(const fs::path& path, std::error_code& ec) override
        {
            fs::SystemHandle res;
            TakeExclusiveFileLockHelper helper(res, path.native());

            if (helper(ec) || ec)
            {
                return res;
            }

            Debug::print("Waiting to take filesystem lock on ", fs::u8string(path), "...\n");
            auto wait = std::chrono::milliseconds(100);
            // waits, at most, a second and a half.
            while (wait < std::chrono::milliseconds(1000))
            {
                std::this_thread::sleep_for(wait);
                if (helper(ec) || ec)
                {
                    return res;
                }
                wait *= 2;
            }

            helper.assign_busy_error(ec);
            return res;
        }

        virtual void unlock_file_lock(fs::SystemHandle handle, std::error_code& ec) override
        {
#if defined(WIN32)
            if (CloseHandle(reinterpret_cast<HANDLE>(handle.system_handle)) == 0)
            {
                ec.assign(GetLastError(), std::system_category());
            }
#else
            if (flock(handle.system_handle, LOCK_UN) != 0 || close(handle.system_handle) != 0)
            {
                ec.assign(errno, std::generic_category());
            }
#endif
        }

        virtual std::vector<fs::path> find_from_PATH(const std::string& name) const override
        {
#if defined(_WIN32)
            static constexpr wchar_t const* EXTS[] = {L".cmd", L".exe", L".bat"};
#else  // ^^^ defined(_WIN32) // !defined(_WIN32) vvv
            static constexpr char const* EXTS[] = {""};
#endif // ^^^!defined(_WIN32)
            auto paths = Strings::split_paths(System::get_environment_variable("PATH").value_or_exit(VCPKG_LINE_INFO));

            std::vector<fs::path> ret;
            for (auto&& path : paths)
            {
                auto base = fs::u8path(path);
                base /= fs::u8path(name);

                for (auto&& ext : EXTS)
                {
                    auto p = fs::path(base.native() + ext);
                    if (Util::find(ret, p) == ret.end() && this->exists(p, ignore_errors))
                    {
                        ret.push_back(p);
                        Debug::print("Found path: ", fs::u8string(p), '\n');
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

    fs::path combine(const fs::path& lhs, const fs::path& rhs)
    {
#if VCPKG_USE_STD_FILESYSTEM
        return lhs / rhs;
#else // ^^^ std::filesystem // std::experimental::filesystem vvv
#if !defined(_WIN32)
        if (rhs.is_absolute())
        {
            return rhs;
        }
        else
        {
            return lhs / rhs;
        }
#else  // ^^^ unix // windows vvv
        auto rhs_root_directory = rhs.root_directory();
        auto rhs_root_name = rhs.root_name();

        if (rhs_root_directory.empty() && rhs_root_name.empty())
        {
            return lhs / rhs;
        }
        else if (rhs_root_directory.empty())
        {
            // !rhs_root_name.empty()
            if (rhs_root_name == lhs.root_name())
            {
                return lhs / rhs.relative_path();
            }
            else
            {
                return rhs;
            }
        }
        else if (rhs_root_name.empty())
        {
            // !rhs_root_directory.empty()
            return lhs.root_name() / rhs;
        }
        else
        {
            // rhs.absolute()
            return rhs;
        }
#endif // ^^^ windows
#endif // ^^^ std::experimental::filesystem
    }

#ifdef _WIN32
    fs::path win32_fix_path_case(const fs::path& source)
    {
        using fs::is_slash;
        const std::wstring& native = source.native();
        if (native.empty())
        {
            return fs::path{};
        }

        if (wide_starts_with(native, L"\\\\?\\") || wide_starts_with(native, L"\\??\\") ||
            wide_starts_with(native, L"\\\\.\\"))
        {
            // no support to attempt to fix paths in the NT, \\GLOBAL??, or device namespaces at this time
            return source;
        }

        const auto last = native.end();
        auto first = native.begin();
        auto is_wildcard = [](wchar_t c) { return c == L'?' || c == L'*'; };
        if (std::any_of(first, last, is_wildcard))
        {
            Checks::exit_with_message(
                VCPKG_LINE_INFO, "Attempt to fix case of a path containing wildcards: %s", fs::u8string(source));
        }

        std::wstring in_progress;
        in_progress.reserve(native.size());
        if (last - first >= 3 && is_slash(first[0]) && is_slash(first[1]) && !is_slash(first[2]))
        {
            // path with UNC prefix \\server\share; this will be rejected by FindFirstFile so we skip over that
            in_progress.push_back(L'\\');
            in_progress.push_back(L'\\');
            first += 2;
            auto next_slash = std::find_if(first, last, is_slash);
            in_progress.append(first, next_slash);
            in_progress.push_back(L'\\');
            first = std::find_if_not(next_slash, last, is_slash);
            next_slash = std::find_if(first, last, is_slash);
            in_progress.append(first, next_slash);
            first = std::find_if_not(next_slash, last, is_slash);
            if (first != next_slash)
            {
                in_progress.push_back(L'\\');
            }
        }
        else if (last - first >= 1 && is_slash(first[0]))
        {
            // root relative path
            in_progress.push_back(L'\\');
            first = std::find_if_not(first, last, is_slash);
        }
        else if (starts_with_drive_letter(first, last))
        {
            // path with drive letter root
            auto letter = first[0];
            if (letter >= L'a' && letter <= L'z')
            {
                letter = letter - L'a' + L'A';
            }

            in_progress.push_back(letter);
            in_progress.push_back(L':');
            first += 2;
            if (first != last && is_slash(*first))
            {
                // absolute path
                in_progress.push_back(L'\\');
                first = std::find_if_not(first, last, is_slash);
            }
        }

        assert(!fs::path(first, last).has_root_path());

        while (first != last)
        {
            auto next_slash = std::find_if(first, last, is_slash);
            auto original_size = in_progress.size();
            in_progress.append(first, next_slash);
            FindFirstOp this_find;
            unsigned long last_error = this_find.find_first(in_progress.c_str());
            if (last_error == ERROR_SUCCESS)
            {
                in_progress.resize(original_size);
                in_progress.append(this_find.find_data.cFileName);
            }
            else
            {
                // we might not have access to this intermediate part of the path;
                // just guess that the case of that element is correct and move on
            }

            first = std::find_if_not(next_slash, last, is_slash);
            if (first != next_slash)
            {
                in_progress.push_back(L'\\');
            }
        }

        return fs::path(std::move(in_progress));
    }
#endif // _WIN32

}
