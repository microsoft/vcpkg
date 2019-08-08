#pragma once

#include <vcpkg/base/expected.h>

#define _SILENCE_EXPERIMENTAL_FILESYSTEM_DEPRECATION_WARNING
#include <experimental/filesystem>

namespace fs
{
    namespace stdfs = std::experimental::filesystem;

    using stdfs::copy_options;
    using stdfs::path;
    using stdfs::perms;
    using stdfs::u8path;

#if defined(_WIN32)
    enum class file_type
    {
        none = 0,
        not_found = -1,
        regular = 1,
        directory = 2,
        symlink = 3,
        block = 4,
        character = 5,
        fifo = 6,
        socket = 7,
        unknown = 8,
        // also stands for a junction
        directory_symlink = 42
    };

    struct file_status
    {
        explicit file_status(file_type type = file_type::none, perms permissions = perms::unknown) noexcept
            : m_type(type), m_permissions(permissions)
        {
        }

        file_type type() const noexcept { return m_type; }
        void type(file_type type) noexcept { m_type = type; }

        perms permissions() const noexcept { return m_permissions; }
        void permissions(perms perm) noexcept { m_permissions = perm; }

    private:
        file_type m_type;
        perms m_permissions;
    };

#else

    using stdfs::file_status;
    using stdfs::file_type;

#endif

    /*
        std::experimental::filesystem's file_status and file_type are broken in
        the presence of symlinks -- a symlink is treated as the object it points
        to for `symlink_status` and `symlink_type`
    */

    // we want to poison ADL with these niebloids

    namespace detail
    {
        struct status_t
        {
            file_status operator()(const path& p, std::error_code& ec) const noexcept;
            file_status operator()(vcpkg::LineInfo li, const path& p) const noexcept;
            file_status operator()(const path& p) const;
        };
        struct symlink_status_t
        {
            file_status operator()(const path& p, std::error_code& ec) const noexcept;
            file_status operator()(vcpkg::LineInfo li, const path& p) const noexcept;
        };
        struct is_symlink_t
        {
            bool operator()(file_status s) const
            {
#if defined(_WIN32)
                return s.type() == file_type::directory_symlink || s.type() == file_type::symlink;
#else
                return stdfs::is_symlink(s);
#endif
            }
        };
        struct is_regular_file_t
        {
            inline bool operator()(file_status s) const
            {
#if defined(_WIN32)
                return s.type() == file_type::regular;
#else
                return stdfs::is_regular_file(s);
#endif
            }
        };
        struct is_directory_t
        {
            inline bool operator()(file_status s) const
            {
#if defined(_WIN32)
                return s.type() == file_type::directory;
#else
                return stdfs::is_directory(s);
#endif
            }
        };
        struct exists_t
        {
            inline bool operator()(file_status s) const
            {
#if defined(_WIN32)
                return s.type() != file_type::not_found && s.type() != file_type::none;
#else
                return stdfs::exists(s);
#endif
            }
        };
    }

    constexpr detail::status_t status{};
    constexpr detail::symlink_status_t symlink_status{};
    constexpr detail::is_symlink_t is_symlink{};
    constexpr detail::is_regular_file_t is_regular_file{};
    constexpr detail::is_directory_t is_directory{};
    constexpr detail::exists_t exists{};
}

/*
    if someone attempts to use unqualified `symlink_status` or `is_symlink`,
    they might get the ADL version, which is broken.
    Therefore, put `symlink_status` in the global namespace, so that they get
    our symlink_status.

    We also want to poison the ADL on the other functions, because
    we don't want people calling these functions on paths
*/
using fs::exists;
using fs::is_directory;
using fs::is_regular_file;
using fs::is_symlink;
using fs::status;
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

        virtual void remove_all(const fs::path& path, std::error_code& ec, fs::path& failure_point) = 0;
        void remove_all(const fs::path& path, LineInfo li);
        bool exists(const fs::path& path, std::error_code& ec) const;
        bool exists(LineInfo li, const fs::path& path) const;
        // this should probably not exist, but would require a pass through of
        // existing code to fix
        bool exists(const fs::path& path) const;
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
