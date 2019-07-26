#include <vcpkg-test/catch.h>
#include <vcpkg-test/util.h>

#include <vcpkg/base/files.h>
#include <vcpkg/base/strings.h>

#include <iostream>
#include <random>

#include <vector>

using vcpkg::Test::SYMLINKS_ALLOWED;
using vcpkg::Test::TEMPORARY_DIRECTORY;

namespace
{
    using uid = std::uniform_int_distribution<std::uint64_t>;

    std::mt19937_64 get_urbg(std::uint64_t index)
    {
        // smallest prime > 2**63 - 1
        return std::mt19937_64{index + 9223372036854775837ULL};
    }

    std::string get_random_filename(std::mt19937_64& urbg) { return vcpkg::Strings::b32_encode(uid{}(urbg)); }

    void create_directory_tree(std::mt19937_64& urbg,
                               vcpkg::Files::Filesystem& fs,
                               std::uint64_t depth,
                               const fs::path& base)
    {
        std::random_device rd;
        constexpr std::uint64_t max_depth = 5;
        constexpr std::uint64_t width = 5;

        // we want ~70% of our "files" to be directories, and then a third
        // each of the remaining ~30% to be regular files, directory symlinks,
        // and regular symlinks
        constexpr std::uint64_t directory_min_tag = 0;
        constexpr std::uint64_t directory_max_tag = 6;
        constexpr std::uint64_t regular_file_tag = 7;
        constexpr std::uint64_t regular_symlink_tag = 8;
        constexpr std::uint64_t directory_symlink_tag = 9;

        // if we're at the max depth, we only want to build non-directories
        std::uint64_t file_type;
        if (depth < max_depth)
        {
            file_type = uid{directory_min_tag, regular_symlink_tag}(urbg);
        }
        else
        {
            file_type = uid{regular_file_tag, regular_symlink_tag}(urbg);
        }

        if (!SYMLINKS_ALLOWED && file_type > regular_file_tag)
        {
            file_type = regular_file_tag;
        }

        std::error_code ec;
        if (file_type <= directory_max_tag)
        {
            fs.create_directory(base, ec);
            if (ec) {
                INFO("File that failed: " << base);
                REQUIRE_FALSE(ec);
            }

            for (int i = 0; i < width; ++i)
            {
                create_directory_tree(urbg, fs, depth + 1, base / get_random_filename(urbg));
            }
        }
        else if (file_type == regular_file_tag)
        {
            // regular file
            fs.write_contents(base, "", ec);
        }
        else if (file_type == regular_symlink_tag)
        {
            // regular symlink
            fs.write_contents(base, "", ec);
            REQUIRE_FALSE(ec);
            auto base_link = base;
            base_link.replace_filename(base.filename().u8string() + "-link");
            vcpkg::Test::create_symlink(base, base_link, ec);
        }
        else // type == directory_symlink_tag
        {
            // directory symlink
            vcpkg::Test::create_directory_symlink(base / "..", base, ec);
        }

        REQUIRE_FALSE(ec);
    }
}

TEST_CASE ("remove all", "[files]")
{
    auto urbg = get_urbg(0);

    fs::path temp_dir = TEMPORARY_DIRECTORY / get_random_filename(urbg);

    auto& fs = vcpkg::Files::get_real_filesystem();

    std::error_code ec;
    fs.create_directory(TEMPORARY_DIRECTORY, ec);

    REQUIRE_FALSE(ec);

    INFO("temp dir is: " << temp_dir);

    create_directory_tree(urbg, fs, 0, temp_dir);

    fs::path fp;
    fs.remove_all(temp_dir, ec, fp);
    if (ec) {
        FAIL("remove_all failure on file: " << fp);
    }

    REQUIRE_FALSE(fs.exists(temp_dir));
}
