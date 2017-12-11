#include "tests.pch.h"

#include <tests.utils.h>

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

using namespace vcpkg;
using namespace vcpkg::Update;

namespace UnitTest1
{
    class UpdateTests : public TestClass<UpdateTests>
    {
        TEST_METHOD(find_outdated_packages_basic)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(make_status_pgh("a"));
            status_paragraphs.back()->package.version = "2";

            StatusParagraphs status_db(std::move(status_paragraphs));

            std::map<std::string, VersionT> port_versions;
            port_versions["a"] = VersionT("0");

            auto pkgs = SortedVector<OutdatedPackage>(Update::find_outdated_packages(port_versions, status_db),
                                                      &OutdatedPackage::compare_by_name);

            Assert::AreEqual(size_t(1), pkgs.size());
            Assert::AreEqual("2", pkgs[0].version_diff.left.to_string().c_str());
            Assert::AreEqual("0", pkgs[0].version_diff.right.to_string().c_str());
        }

        TEST_METHOD(find_outdated_packages_features)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(make_status_pgh("a"));
            status_paragraphs.back()->package.version = "2";

            status_paragraphs.push_back(make_status_feature_pgh("a", "b"));
            status_paragraphs.back()->package.version = "2";

            StatusParagraphs status_db(std::move(status_paragraphs));

            std::map<std::string, VersionT> port_versions;
            port_versions["a"] = VersionT("0");

            auto pkgs = SortedVector<OutdatedPackage>(Update::find_outdated_packages(port_versions, status_db),
                                                      &OutdatedPackage::compare_by_name);

            Assert::AreEqual(size_t(1), pkgs.size());
            Assert::AreEqual("2", pkgs[0].version_diff.left.to_string().c_str());
            Assert::AreEqual("0", pkgs[0].version_diff.right.to_string().c_str());
        }

        TEST_METHOD(find_outdated_packages_features_2)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(make_status_pgh("a"));
            status_paragraphs.back()->package.version = "2";

            status_paragraphs.push_back(make_status_feature_pgh("a", "b"));
            status_paragraphs.back()->package.version = "0";
            status_paragraphs.back()->state = InstallState::NOT_INSTALLED;
            status_paragraphs.back()->want = Want::PURGE;

            StatusParagraphs status_db(std::move(status_paragraphs));

            std::map<std::string, VersionT> port_versions;
            port_versions["a"] = VersionT("0");

            auto pkgs = SortedVector<OutdatedPackage>(Update::find_outdated_packages(port_versions, status_db),
                                                      &OutdatedPackage::compare_by_name);

            Assert::AreEqual(size_t(1), pkgs.size());
            Assert::AreEqual("2", pkgs[0].version_diff.left.to_string().c_str());
            Assert::AreEqual("0", pkgs[0].version_diff.right.to_string().c_str());
        }

        TEST_METHOD(find_outdated_packages_none)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(make_status_pgh("a"));
            status_paragraphs.back()->package.version = "2";

            StatusParagraphs status_db(std::move(status_paragraphs));

            std::map<std::string, VersionT> port_versions;
            port_versions["a"] = VersionT("2");

            auto pkgs = SortedVector<OutdatedPackage>(Update::find_outdated_packages(port_versions, status_db),
                                                      &OutdatedPackage::compare_by_name);

            Assert::AreEqual(size_t(0), pkgs.size());
        }
    };
}
