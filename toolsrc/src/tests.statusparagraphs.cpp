#include "tests.pch.h"

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

using namespace vcpkg;
using namespace vcpkg::Paragraphs;

namespace UnitTest1
{
    class StatusParagraphsTests : public TestClass<StatusParagraphsTests>
    {
        TEST_METHOD(find_installed)
        {
            auto pghs = parse_paragraphs(R"(
Package: ffmpeg
Version: 3.3.3
Architecture: x64-windows
Multi-Arch: same
Description:
Status: install ok installed
)");
            Assert::IsTrue(!!pghs);
            if (!pghs) return;

            StatusParagraphs status_db(Util::fmap(
                *pghs.get(), [](RawParagraph& rpgh) { return std::make_unique<StatusParagraph>(std::move(rpgh)); }));

            auto it = status_db.find_installed("ffmpeg", Triplet::X64_WINDOWS);
            Assert::IsTrue(it != status_db.end());
        }

        TEST_METHOD(find_not_installed)
        {
            auto pghs = parse_paragraphs(R"(
Package: ffmpeg
Version: 3.3.3
Architecture: x64-windows
Multi-Arch: same
Description:
Status: purge ok not-installed
)");
            Assert::IsTrue(!!pghs);
            if (!pghs) return;

            StatusParagraphs status_db(Util::fmap(
                *pghs.get(), [](RawParagraph& rpgh) { return std::make_unique<StatusParagraph>(std::move(rpgh)); }));

            auto it = status_db.find_installed("ffmpeg", Triplet::X64_WINDOWS);
            Assert::IsTrue(it == status_db.end());
        }

        TEST_METHOD(find_with_feature_packages)
        {
            auto pghs = parse_paragraphs(R"(
Package: ffmpeg
Version: 3.3.3
Architecture: x64-windows
Multi-Arch: same
Description:
Status: install ok installed

Package: ffmpeg
Feature: openssl
Depends: openssl
Architecture: x64-windows
Multi-Arch: same
Description:
Status: purge ok not-installed
)");
            Assert::IsTrue(!!pghs);
            if (!pghs) return;

            StatusParagraphs status_db(Util::fmap(
                *pghs.get(), [](RawParagraph& rpgh) { return std::make_unique<StatusParagraph>(std::move(rpgh)); }));

            auto it = status_db.find_installed("ffmpeg", Triplet::X64_WINDOWS);
            Assert::IsTrue(it != status_db.end());
        }
    };
}