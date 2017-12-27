#include "tests.pch.h"

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

namespace Chrono = vcpkg::Chrono;

namespace UnitTest1
{
    class ChronoTests : public TestClass<ChronoTests>
    {
        TEST_METHOD(parse_time)
        {
            auto timestring = "1990-02-03T04:05:06.0Z";
            auto maybe_time = Chrono::CTime::parse(timestring);

            Assert::IsTrue(maybe_time.has_value());

            Assert::AreEqual(timestring, maybe_time.get()->to_string().c_str());
        }

        TEST_METHOD(parse_time_blank)
        {
            auto maybe_time = Chrono::CTime::parse("");

            Assert::IsFalse(maybe_time.has_value());
        }

        TEST_METHOD(time_difference)
        {
            auto maybe_time1 = Chrono::CTime::parse("1990-02-03T04:05:06.0Z");
            auto maybe_time2 = Chrono::CTime::parse("1990-02-10T04:05:06.0Z");

            Assert::IsTrue(maybe_time1.has_value());
            Assert::IsTrue(maybe_time2.has_value());

            auto delta = maybe_time2.get()->to_time_point() - maybe_time1.get()->to_time_point();

            Assert::AreEqual(24 * 7, std::chrono::duration_cast<std::chrono::hours>(delta).count());
        }
    };
}
