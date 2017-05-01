#pragma once

#include <filesystem>

namespace fs
{
    namespace stdfs = std::tr2::sys;

    using stdfs::path;
    using stdfs::copy_options;
    using stdfs::file_status;

    inline bool is_regular_file(file_status s) { return stdfs::is_regular_file(s); }
    inline bool is_directory(file_status s) { return stdfs::is_directory(s); }
    inline bool status_known(file_status s) { return stdfs::status_known(s); }
}