#include "tests.pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/strings.h>

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
                HKEY_LOCAL_MACHINE, LR"(SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock)", 0, KEY_READ, &key);

            if (!status)
            {
                ALLOW_SYMLINKS = false;
                std::clog << "Symlinks are not allowed on this system\n";
            }
            else
            {
                ALLOW_SYMLINKS = true;
                RegCloseKey(key);
            }
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

            std::error_code ec;
            create_directory_tree(urbg, fs, 0, temp_dir);

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

        std::string get_random_filename(std::mt19937_64& urbg) { return vcpkg::Strings::b64url_encode(uid{}(urbg)); }

        void create_directory_tree(std::mt19937_64& urbg,
                                   vcpkg::Files::Filesystem& fs,
                                   std::uint64_t depth,
                                   const fs::path& base)
        {
            std::random_device rd;
            constexpr auto max_depth = std::uint64_t(3);
            const auto width = depth ? uid{0, (max_depth - depth) * 3 / 2}(urbg) : 5;

            std::error_code ec;
            if (width == 0)
            {
                // I don't want to move urbg forward conditionally
                const auto type = uid{0, 3}(urbg);
                if (type == 0 || !ALLOW_SYMLINKS)
                {
                    // 0 is a regular file
                    fs.write_contents(base, "", ec);
                }
                else if (type == 1)
                {
                    // 1 is a regular symlink
                    fs.write_contents(base, "", ec);
                    Assert::IsFalse(bool(ec));
                    fs::path base_link = base;
                    base_link.append("-link");
                    fs::stdfs::create_symlink(base, base_link, ec);
                }
                else
                {
                    // 2 is a directory symlink
                    fs::stdfs::create_directory_symlink(".", base, ec);
                }

                Assert::IsFalse(bool(ec));

                return;
            }

            fs.create_directory(base, ec);
            Assert::IsFalse(bool(ec));

            for (int i = 0; i < width; ++i)
            {
                create_directory_tree(urbg, fs, depth + 1, base / get_random_filename(urbg));
            }
        }
    };
}
