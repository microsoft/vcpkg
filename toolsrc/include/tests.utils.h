#pragma once

#include <CppUnitTest.h>

#include <vcpkg/dependencies.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/packagespecparseresult.h>
#include <vcpkg/statusparagraph.h>
#include <vcpkg/triplet.h>

#include <memory>

namespace Microsoft::VisualStudio::CppUnitTestFramework
{
    template<>
    inline std::wstring ToString<vcpkg::Dependencies::InstallPlanType>(const vcpkg::Dependencies::InstallPlanType& t)
    {
        switch (t)
        {
            case vcpkg::Dependencies::InstallPlanType::ALREADY_INSTALLED: return L"ALREADY_INSTALLED";
            case vcpkg::Dependencies::InstallPlanType::BUILD_AND_INSTALL: return L"BUILD_AND_INSTALL";
            case vcpkg::Dependencies::InstallPlanType::EXCLUDED: return L"EXCLUDED";
            case vcpkg::Dependencies::InstallPlanType::UNKNOWN: return L"UNKNOWN";
            default: return ToString(static_cast<int>(t));
        }
    }

    template<>
    inline std::wstring ToString<vcpkg::Dependencies::RequestType>(const vcpkg::Dependencies::RequestType& t)
    {
        switch (t)
        {
            case vcpkg::Dependencies::RequestType::AUTO_SELECTED: return L"AUTO_SELECTED";
            case vcpkg::Dependencies::RequestType::USER_REQUESTED: return L"USER_REQUESTED";
            case vcpkg::Dependencies::RequestType::UNKNOWN: return L"UNKNOWN";
            default: return ToString(static_cast<int>(t));
        }
    }

    template<>
    inline std::wstring ToString<vcpkg::PackageSpecParseResult>(const vcpkg::PackageSpecParseResult& t)
    {
        return ToString(static_cast<uint32_t>(t));
    }

    template<>
    inline std::wstring ToString<vcpkg::PackageSpec>(const vcpkg::PackageSpec& t)
    {
        return ToString(t.to_string());
    }
}

std::unique_ptr<vcpkg::StatusParagraph> make_status_pgh(const char* name,
                                                        const char* depends = "",
                                                        const char* default_features = "",
                                                        const char* triplet = "x86-windows");
std::unique_ptr<vcpkg::StatusParagraph> make_status_feature_pgh(const char* name,
                                                                const char* feature,
                                                                const char* depends = "",
                                                                const char* triplet = "x86-windows");

template<class T, class S>
T&& unwrap(vcpkg::ExpectedT<T, S>&& p)
{
    Assert::IsTrue(p.has_value());
    return std::move(*p.get());
}

template<class T>
T&& unwrap(vcpkg::Optional<T>&& opt)
{
    Assert::IsTrue(opt.has_value());
    return std::move(*opt.get());
}

vcpkg::PackageSpec unsafe_pspec(std::string name, vcpkg::Triplet t = vcpkg::Triplet::X86_WINDOWS);
