#pragma once

#include <vcpkg/base/files.h>

#include <string>

namespace vcpkg
{
    struct UserConfig
    {
        std::string user_id;
        std::string user_time;
        std::string user_mac;

        std::string last_completed_survey;

        static UserConfig try_read_data(const Files::Filesystem& fs);

        void try_write_data(Files::Filesystem& fs) const;
    };

    fs::path get_user_dir();
}
