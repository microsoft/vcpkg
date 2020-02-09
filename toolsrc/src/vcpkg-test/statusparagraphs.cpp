#include <catch2/catch.hpp>
#include <vcpkg-test/util.h>

#include <vcpkg/base/util.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/statusparagraphs.h>

using namespace vcpkg;
using namespace vcpkg::Paragraphs;
using namespace vcpkg::Test;

TEST_CASE ("find installed", "[statusparagraphs]")
{
    auto pghs = parse_paragraphs(R"(
Package: ffmpeg
Version: 3.3.3
Architecture: x64-windows
Multi-Arch: same
Description:
Status: install ok installed
)",
                                 "");

    REQUIRE(pghs);

    StatusParagraphs status_db(
        Util::fmap(*pghs.get(), [](RawParagraph& rpgh) { return std::make_unique<StatusParagraph>(std::move(rpgh)); }));

    auto it = status_db.find_installed({"ffmpeg", Triplet::X64_WINDOWS});
    REQUIRE(it != status_db.end());
}

TEST_CASE ("find not installed", "[statusparagraphs]")
{
    auto pghs = parse_paragraphs(R"(
Package: ffmpeg
Version: 3.3.3
Architecture: x64-windows
Multi-Arch: same
Description:
Status: purge ok not-installed
)",
                                 "");

    REQUIRE(pghs);

    StatusParagraphs status_db(
        Util::fmap(*pghs.get(), [](RawParagraph& rpgh) { return std::make_unique<StatusParagraph>(std::move(rpgh)); }));

    auto it = status_db.find_installed({"ffmpeg", Triplet::X64_WINDOWS});
    REQUIRE(it == status_db.end());
}

TEST_CASE ("find with feature packages", "[statusparagraphs]")
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
)",
                                 "");

    REQUIRE(pghs);

    StatusParagraphs status_db(
        Util::fmap(*pghs.get(), [](RawParagraph& rpgh) { return std::make_unique<StatusParagraph>(std::move(rpgh)); }));

    auto it = status_db.find_installed({"ffmpeg", Triplet::X64_WINDOWS});
    REQUIRE(it != status_db.end());

    // Feature "openssl" is not installed and should not be found
    auto it1 = status_db.find_installed({{"ffmpeg", Triplet::X64_WINDOWS}, "openssl"});
    REQUIRE(it1 == status_db.end());
}

TEST_CASE ("find for feature packages", "[statusparagraphs]")
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
Status: install ok installed
)",
                                 "");
    REQUIRE(pghs);

    StatusParagraphs status_db(
        Util::fmap(*pghs.get(), [](RawParagraph& rpgh) { return std::make_unique<StatusParagraph>(std::move(rpgh)); }));

    // Feature "openssl" is installed and should therefore be found
    auto it = status_db.find_installed({{"ffmpeg", Triplet::X64_WINDOWS}, "openssl"});
    REQUIRE(it != status_db.end());
}
