#include "tests.pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/strings.h>

#include <iostream>
#include <random>

#include <windows.h>

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

namespace UnitTest1 {
    class FilesTest : public TestClass<FilesTest> {
        using uid = std::uniform_int_distribution<std::uint64_t>;
        
        std::string get_random_filename()
        {
            std::random_device rd;
            return vcpkg::Strings::b64url_encode(uid{}(rd));
        }
        
        void create_directory_tree(
            vcpkg::Files::Filesystem& fs,
            std::uint64_t depth,
            const fs::path& base)
        {
            std::random_device rd;
            constexpr auto max_depth = std::uint64_t(3);
            const auto width = depth ? uid{0, (max_depth - depth) * 3 / 2}(rd) : 5;

            std::error_code ec;
            if (width == 0) {
                fs.write_contents(base, "", ec);
                Assert::IsFalse(bool(ec));

                return;
            }

            fs.create_directory(base, ec);
            Assert::IsFalse(bool(ec));

            for (int i = 0; i < width; ++i) {
                create_directory_tree(fs, depth + 1, base / get_random_filename());
            }
        }
		
        TEST_METHOD(remove_all) {
            fs::path temp_dir;

            {
                wchar_t* tmp = static_cast<wchar_t*>(calloc(32'767, 2));

                if (!GetEnvironmentVariableW(L"TEMP", tmp, 32'767)) {
                    Assert::Fail(L"GetEnvironmentVariable(\"TEMP\") failed");
                }

                temp_dir = tmp;

                std::string dir_name = "vcpkg-tmp-dir-";
                dir_name += get_random_filename();

                temp_dir /= dir_name;
            }

            auto& fs = vcpkg::Files::get_real_filesystem();

			std::cout << "temp dir is: " << temp_dir << '\n';

            std::error_code ec;
			create_directory_tree(fs, 0, temp_dir);

            fs::path fp;
            fs.remove_all(temp_dir, ec, fp);
            Assert::IsFalse(bool(ec));

            Assert::IsFalse(fs.exists(temp_dir));
        }
    };
}
