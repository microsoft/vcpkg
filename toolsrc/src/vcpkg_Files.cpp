#include "vcpkg_Files.h"
#include <fstream>
#include <filesystem>

namespace fs = std::tr2::sys;

namespace vcpkg {namespace Files
{
    void check_is_directory(const fs::path& dirpath)
    {
        Checks::check_throw(fs::is_directory(dirpath), "The path %s is not a directory", dirpath.string());
    }

    expected<std::string> get_contents(const fs::path& file_path) noexcept
    {
        std::fstream file_stream(file_path, std::ios_base::in | std::ios_base::binary);
        if (file_stream.fail())
        {
            return std::errc::no_such_file_or_directory;
        }

        file_stream.seekg(0, file_stream.end);
        auto length = file_stream.tellg();
        file_stream.seekg(0, file_stream.beg);

        if (length > SIZE_MAX)
        {
            return std::errc::file_too_large;
        }

        std::string output;
        output.resize(static_cast<size_t>(length));
        file_stream.read(&output[0], length);
        file_stream.close();

        return std::move(output);
    }

    fs::path find_file_recursively_up(const fs::path& starting_dir, const std::string& filename)
    {
        fs::path current_dir = starting_dir;
        for (; !current_dir.empty(); current_dir = current_dir.parent_path())
        {
            const fs::path candidate = current_dir / filename;
            if (fs::exists(candidate))
            {
                break;
            }
        }

        return current_dir;
    }
}}
