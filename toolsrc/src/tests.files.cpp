#include "tests.pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/strings.h>

#include <filesystem> // required for filesystem::create_{directory_}symlink
#include <iostream>
#include <random>

#include <windows.h>

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

namespace UnitTest1
{
    class FilesTest : public TestClass<FilesTest>
    {
        using uid = std::uniform_int_distribution<std::uint64_t>;

    public:
        FilesTest()
        {
            HKEY key;
            const auto status = RegOpenKeyExW(
                HKEY_LOCAL_MACHINE, LR"(SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock)", 0, 0, &key);

            if (status == ERROR_FILE_NOT_FOUND)
            {
                ALLOW_SYMLINKS = false;
                std::clog << "Symlinks are not allowed on this system\n";
            }
            else
            {
                // if we get a permissions error, we still know that we're in developer mode
                ALLOW_SYMLINKS = true;
            }

            if (status == ERROR_SUCCESS) RegCloseKey(key);
        }

    private:
        TEST_METHOD(remove_all)
        {
            auto urbg = get_urbg(0);

            fs::path temp_dir;

            {
                wchar_t* tmp = static_cast<wchar_t*>(calloc(32'767, 2));

                if (!GetEnvironmentVariableW(L"TEMP", tmp, 32'767))
                {
                    Assert::Fail(L"GetEnvironmentVariable(\"TEMP\") failed");
                }

                temp_dir = tmp;

                std::string dir_name = "vcpkg-tmp-dir-";
                dir_name += get_random_filename(urbg);

                temp_dir /= dir_name;
            }

            auto& fs = vcpkg::Files::get_real_filesystem();

            std::clog << "temp dir is: " << temp_dir << '\n';

            create_directory_tree(urbg, fs, 0, temp_dir);

            std::error_code ec;
            fs::path fp;
            fs.remove_all(temp_dir, ec, fp);
            Assert::IsFalse(bool(ec));

            Assert::IsFalse(fs.exists(temp_dir));
        }

        bool ALLOW_SYMLINKS;

        std::mt19937_64 get_urbg(std::uint64_t index)
        {
            // smallest prime > 2**63 - 1
            return std::mt19937_64{index + 9223372036854775837};
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

            if (!ALLOW_SYMLINKS && file_type > regular_file_tag)
            {
                file_type = regular_file_tag;
            }

            std::error_code ec;
            if (type <= directory_max_tag)
            {
                fs.create_directory(base, ec);
                Assert::IsFalse(bool(ec));

                for (int i = 0; i < width; ++i)
                {
                    create_directory_tree(urbg, fs, depth + 1, base / get_random_filename(urbg));
                }
            }
            else if (type == regular_file_tag)
            {
                // regular file
                fs.write_contents(base, "", ec);
            }
            else if (type == regular_symlink_tag)
            {
                // regular symlink
                fs.write_contents(base, "", ec);
                Assert::IsFalse(bool(ec));
                const std::filesystem::path basep = base.native();
                auto basep_link = basep;
                basep_link.replace_filename(basep.filename().native() + L"-link");
                std::filesystem::create_symlink(basep, basep_link, ec);
            }
            else // type == directory_symlink_tag
            {
                // directory symlink
                std::filesystem::path basep = base.native();
                std::filesystem::create_directory_symlink(basep / "..", basep, ec);
            }

            Assert::IsFalse(bool(ec));
        }
    };
}
