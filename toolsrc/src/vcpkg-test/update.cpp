#include <catch2/catch.hpp>
#include <vcpkg-test/util.h>

#include <vcpkg/base/sortedvector.h>

#include <vcpkg/update.h>

using namespace vcpkg;
using namespace vcpkg::Update;
using namespace vcpkg::Test;

using Pgh = std::vector<std::unordered_map<std::string, std::string>>;

TEST_CASE ("find outdated packages basic", "[update]")
{
    std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
    status_paragraphs.push_back(make_status_pgh("a"));
    status_paragraphs.back()->package.version = "2";

    StatusParagraphs status_db(std::move(status_paragraphs));

    std::unordered_map<std::string, SourceControlFileLocation> map;
    auto scf = unwrap(SourceControlFile::parse_control_file(Pgh{{{"Source", "a"}, {"Version", "0"}}}));
    map.emplace("a", SourceControlFileLocation{std::move(scf), ""});
    Dependencies::MapPortFileProvider provider(map);

    auto pkgs = SortedVector<OutdatedPackage>(Update::find_outdated_packages(provider, status_db),
                                              &OutdatedPackage::compare_by_name);

    REQUIRE(pkgs.size() == 1);
    REQUIRE(pkgs[0].version_diff.left.to_string() == "2");
    REQUIRE(pkgs[0].version_diff.right.to_string() == "0");
}

TEST_CASE ("find outdated packages features", "[update]")
{
    std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
    status_paragraphs.push_back(make_status_pgh("a"));
    status_paragraphs.back()->package.version = "2";

    status_paragraphs.push_back(make_status_feature_pgh("a", "b"));
    status_paragraphs.back()->package.version = "2";

    StatusParagraphs status_db(std::move(status_paragraphs));

    std::unordered_map<std::string, SourceControlFileLocation> map;
    auto scf = unwrap(SourceControlFile::parse_control_file(Pgh{{{"Source", "a"}, {"Version", "0"}}}));
    map.emplace("a", SourceControlFileLocation{std::move(scf), ""});
    Dependencies::MapPortFileProvider provider(map);

    auto pkgs = SortedVector<OutdatedPackage>(Update::find_outdated_packages(provider, status_db),
                                              &OutdatedPackage::compare_by_name);

    REQUIRE(pkgs.size() == 1);
    REQUIRE(pkgs[0].version_diff.left.to_string() == "2");
    REQUIRE(pkgs[0].version_diff.right.to_string() == "0");
}

TEST_CASE ("find outdated packages features 2", "[update]")
{
    std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
    status_paragraphs.push_back(make_status_pgh("a"));
    status_paragraphs.back()->package.version = "2";

    status_paragraphs.push_back(make_status_feature_pgh("a", "b"));
    status_paragraphs.back()->package.version = "0";
    status_paragraphs.back()->state = InstallState::NOT_INSTALLED;
    status_paragraphs.back()->want = Want::PURGE;

    StatusParagraphs status_db(std::move(status_paragraphs));

    std::unordered_map<std::string, SourceControlFileLocation> map;
    auto scf = unwrap(SourceControlFile::parse_control_file(Pgh{{{"Source", "a"}, {"Version", "0"}}}));
    map.emplace("a", SourceControlFileLocation{std::move(scf), ""});
    Dependencies::MapPortFileProvider provider(map);

    auto pkgs = SortedVector<OutdatedPackage>(Update::find_outdated_packages(provider, status_db),
                                              &OutdatedPackage::compare_by_name);

    REQUIRE(pkgs.size() == 1);
    REQUIRE(pkgs[0].version_diff.left.to_string() == "2");
    REQUIRE(pkgs[0].version_diff.right.to_string() == "0");
}

TEST_CASE ("find outdated packages none", "[update]")
{
    std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
    status_paragraphs.push_back(make_status_pgh("a"));
    status_paragraphs.back()->package.version = "2";

    StatusParagraphs status_db(std::move(status_paragraphs));

    std::unordered_map<std::string, SourceControlFileLocation> map;
    auto scf = unwrap(SourceControlFile::parse_control_file(Pgh{{{"Source", "a"}, {"Version", "2"}}}));
    map.emplace("a", SourceControlFileLocation{std::move(scf), ""});
    Dependencies::MapPortFileProvider provider(map);

    auto pkgs = SortedVector<OutdatedPackage>(Update::find_outdated_packages(provider, status_db),
                                              &OutdatedPackage::compare_by_name);

    REQUIRE(pkgs.size() == 0);
}
