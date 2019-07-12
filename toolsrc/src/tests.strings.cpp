#include "tests.pch.h"

#include <vcpkg/base/strings.h>

#include <cstdint>
#include <utility>
#include <vector>

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

namespace UnitTest1 {
    class StringsTest : public TestClass<StringsTest> {
        TEST_METHOD(b64url_encode)
        {
            using u64 = std::uint64_t;

            std::vector<std::pair<std::uint64_t, std::string>> map;

            map.emplace_back(0, "AAAAAAAAAAA");
            map.emplace_back(1, "BAAAAAAAAAA");

            map.emplace_back(u64(1) << 32, "AAAAAEAAAAA");
            map.emplace_back((u64(1) << 32) + 1, "BAAAAEAAAAA");

            map.emplace_back(0xE4D0'1065'D11E'0229, "pIgHRXGEQTO");
            map.emplace_back(0xA626'FE45'B135'07FF, "_fQNxWk_mYK");
            map.emplace_back(0xEE36'D228'0C31'D405, "FQdMMgi024O");
            map.emplace_back(0x1405'64E7'FE7E'A88C, "Miqf-fOZFQB");
            map.emplace_back(0xFFFF'FFFF'FFFF'FFFF, "__________P");

            std::string result;
            for (const auto& pr : map) {
                result = vcpkg::Strings::b64url_encode(pr.first);
                Assert::AreEqual(result, pr.second);
            }
        }
    };
}
