#pragma once

#include <vcpkg/base/expected.h>

#define _SILENCE_EXPERIMENTAL_FILESYSTEM_DEPRECATION_WARNING
#include <experimental/filesystem>

namespace fs
{
    namespace stdfs = std::experimental::filesystem;

    using stdfs::copy_options;
    using stdfs::file_status;
    using stdfs::file_type;
    using stdfs::path;
    using stdfs::perms;
    using stdfs::u8path;

    /*
        std::experimental::filesystem's file_status and file_type are broken in
        the presence of symlinks -- a symlink is treated as the object it points
        to for `symlink_status` and `symlink_type`
    */

    using stdfs::status;

    // we want to poison ADL with these niebloids

    namespace detail
    {
        struct symlink_status_t
        {
            file_status operator()(const path& p, std::error_code& ec) const noexcept;
            file_status operator()(vcpkg::LineInfo li, const path& p) const noexcept;
        };
        struct is_symlink_t
        {
            inline bool operator()(file_status s) const { return stdfs::is_symlink(s); }
        };
        struct is_regular_file_t
        {
            inline bool operator()(file_status s) const { return stdfs::is_regular_file(s); }
        };
        struct is_directory_t
        {
            inline bool operator()(file_status s) const { return stdfs::is_directory(s); }
        };
    }

    constexpr detail::symlink_status_t symlink_status{};
    constexpr detail::is_symlink_t is_symlink{};
    constexpr detail::is_regular_file_t is_regular_file{};
    constexpr detail::is_directory_t is_directory{};
}

/*
    if someone attempts to use unqualified `symlink_status` or `is_symlink`,
    they might get the ADL version, which is broken.
    Therefore, put `symlink_status` in the global namespace, so that they get
    our symlink_status.

    We also want to poison the ADL on is_regular_file and is_directory, because
    we don't want people calling these functions on paths
*/
using fs::is_directory;
using fs::is_regular_file;
using fs::is_symlink;
using fs::symlink_status;

namespace vcpkg::Files
{
    struct Filesystem
    {
        std::string read_contents(const fs::path& file_path, LineInfo linfo) const;
        virtual Expected<std::string> read_contents(const fs::path& file_path) const = 0;
        virtual Expected<std::vector<std::string>> read_lines(const fs::path& file_path) const = 0;
        virtual fs::path find_file_recursively_up(const fs::path& starting_dir, const std::string& filename) const = 0;
        virtual std::vector<fs::path> get_files_recursive(const fs::path& dir) const = 0;
        virtual std::vector<fs::path> get_files_non_recursive(const fs::path& dir) const = 0;
        void write_lines(const fs::path& file_path, const std::vector<std::string>& lines, LineInfo linfo);
        virtual void write_lines(const fs::path& file_path,
                                 const std::vector<std::string>& lines,
                                 std::error_code& ec) = 0;
        void write_contents(const fs::path& path, const std::string& data, LineInfo linfo);
        virtual void write_contents(const fs::path& file_path, const std::string& data, std::error_code& ec) = 0;
        void rename(const fs::path& oldpath, const fs::path& newpath, LineInfo linfo);
        virtual void rename(const fs::path& oldpath, const fs::path& newpath, std::error_code& ec) = 0;
        virtual void rename_or_copy(const fs::path& oldpath,
                                    const fs::path& newpath,
                                    StringLiteral temp_suffix,
                                    std::error_code& ec) = 0;
        bool remove(const fs::path& path, LineInfo linfo);
        virtual bool remove(const fs::path& path, std::error_code& ec) = 0;

        virtual std::uintmax_t remove_all(const fs::path& path, std::error_code& ec, fs::path& failure_point) = 0;
        std::uintmax_t remove_all(const fs::path& path, LineInfo li);
        virtual bool exists(const fs::path& path) const = 0;
        virtual bool is_directory(const fs::path& path) const = 0;
        virtual bool is_regular_file(const fs::path& path) const = 0;
        virtual bool is_empty(const fs::path& path) const = 0;
        virtual bool create_directory(const fs::path& path, std::error_code& ec) = 0;
        virtual bool create_directories(const fs::path& path, std::error_code& ec) = 0;
        virtual void copy(const fs::path& oldpath, const fs::path& newpath, fs::copy_options opts) = 0;
        virtual bool copy_file(const fs::path& oldpath,
                               const fs::path& newpath,
                               fs::copy_options opts,
                               std::error_code& ec) = 0;
        virtual void copy_symlink(const fs::path& oldpath, const fs::path& newpath, std::error_code& ec) = 0;
        virtual fs::file_status status(const fs::path& path, std::error_code& ec) const = 0;
        virtual fs::file_status symlink_status(const fs::path& path, std::error_code& ec) const = 0;

        virtual std::vector<fs::path> find_from_PATH(const std::string& name) const = 0;
    };

    Filesystem& get_real_filesystem();

    static constexpr const char* FILESYSTEM_INVALID_CHARACTERS = R"(\/:*?"<>|)";

    bool has_invalid_chars_for_filesystem(const std::string& s);

    void print_paths(const std::vector<fs::path>& paths);
}
