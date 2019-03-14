#pragma once

#include <vcpkg/base/expected.h>

#if defined(_WIN32) || defined(__cpp_lib_filesystem)
#include <filesystem>
#else
#include <experimental/filesystem>
#endif

namespace fs
{
// VS2015 (_MSC_VER 1900) uses std::experimental::filesystem
#if (defined(_MSC_VER) && _MSC_VER > 1900) || defined(__cpp_lib_filesystem)
    namespace stdfs = std::filesystem;
#else
    namespace stdfs = std::experimental::filesystem;
#endif

    using stdfs::copy_options;
    using stdfs::file_status;
    using stdfs::file_type;
    using stdfs::path;
    using stdfs::u8path;

    inline bool is_regular_file(file_status s) { return stdfs::is_regular_file(s); }
    inline bool is_directory(file_status s) { return stdfs::is_directory(s); }
    inline bool is_symlink(file_status s) { return stdfs::is_symlink(s); }
}

namespace vcpkg::Files
{
    struct Filesystem
    {
        virtual Expected<std::string> read_contents(const fs::path& file_path) const = 0;
        virtual Expected<std::vector<std::string>> read_lines(const fs::path& file_path) const = 0;
        virtual fs::path find_file_recursively_up(const fs::path& starting_dir, const std::string& filename) const = 0;
        virtual std::vector<fs::path> get_files_recursive(const fs::path& dir) const = 0;
        virtual std::vector<fs::path> get_files_non_recursive(const fs::path& dir) const = 0;

        virtual void write_lines(const fs::path& file_path, const std::vector<std::string>& lines) = 0;
        virtual void write_contents(const fs::path& file_path, const std::string& data, std::error_code& ec) = 0;
        virtual void rename(const fs::path& oldpath, const fs::path& newpath) = 0;
        virtual void rename(const fs::path& oldpath, const fs::path& newpath, std::error_code& ec) = 0;
        virtual void rename_or_copy(const fs::path& oldpath,
                                    const fs::path& newpath,
                                    StringLiteral temp_suffix,
                                    std::error_code& ec) = 0;
        virtual bool remove(const fs::path& path) = 0;
        virtual bool remove(const fs::path& path, std::error_code& ec) = 0;
        virtual std::uintmax_t remove_all(const fs::path& path, std::error_code& ec) = 0;
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

        void write_contents(const fs::path& file_path, const std::string& data);
    };

    Filesystem& get_real_filesystem();

    static constexpr const char* FILESYSTEM_INVALID_CHARACTERS = R"(\/:*?"<>|)";

    bool has_invalid_chars_for_filesystem(const std::string& s);

    void print_paths(const std::vector<fs::path>& paths);
}
