#include "tests.pch.h"

#include "tests.utils.h"

using namespace Microsoft::VisualStudio::CppUnitTestFramework;
using namespace vcpkg;

namespace Microsoft::VisualStudio::CppUnitTestFramework
{
    std::wstring ToString(const vcpkg::Dependencies::InstallPlanType& t)
    {
        switch (t)
        {
            case Dependencies::InstallPlanType::ALREADY_INSTALLED: return L"ALREADY_INSTALLED";
            case Dependencies::InstallPlanType::BUILD_AND_INSTALL: return L"BUILD_AND_INSTALL";
            case Dependencies::InstallPlanType::EXCLUDED: return L"EXCLUDED";
            case Dependencies::InstallPlanType::UNKNOWN: return L"UNKNOWN";
            default: return ToString(static_cast<int>(t));
        }
    }

    std::wstring ToString(const vcpkg::Dependencies::RequestType& t)
    {
        switch (t)
        {
            case Dependencies::RequestType::AUTO_SELECTED: return L"AUTO_SELECTED";
            case Dependencies::RequestType::USER_REQUESTED: return L"USER_REQUESTED";
            case Dependencies::RequestType::UNKNOWN: return L"UNKNOWN";
            default: return ToString(static_cast<int>(t));
        }
    }

    std::wstring ToString(const vcpkg::PackageSpecParseResult& t) { return ToString(static_cast<uint32_t>(t)); }

    std::wstring ToString(const vcpkg::PackageSpec& t) { return ToString(t.to_string()); }
}

std::unique_ptr<StatusParagraph> make_status_pgh(const char* name,
                                                 const char* depends,
                                                 const char* default_features,
                                                 const char* triplet)
{
    using Pgh = std::unordered_map<std::string, std::string>;
    return std::make_unique<StatusParagraph>(Pgh{{"Package", name},
                                                 {"Version", "1"},
                                                 {"Architecture", triplet},
                                                 {"Multi-Arch", "same"},
                                                 {"Depends", depends},
                                                 {"Default-Features", default_features},
                                                 {"Status", "install ok installed"}});
}
std::unique_ptr<StatusParagraph> make_status_feature_pgh(const char* name,
                                                         const char* feature,
                                                         const char* depends,
                                                         const char* triplet)
{
    using Pgh = std::unordered_map<std::string, std::string>;
    return std::make_unique<StatusParagraph>(Pgh{{"Package", name},
                                                 {"Version", "1"},
                                                 {"Feature", feature},
                                                 {"Architecture", triplet},
                                                 {"Multi-Arch", "same"},
                                                 {"Depends", depends},
                                                 {"Status", "install ok installed"}});
}

PackageSpec unsafe_pspec(std::string name, Triplet t)
{
    auto m_ret = PackageSpec::from_name_and_triplet(name, t);
    Assert::IsTrue(m_ret.has_value());
    return m_ret.value_or_exit(VCPKG_LINE_INFO);
}
