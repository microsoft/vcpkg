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
    std::wstring ToString(const vcpkg::Dependencies::InstallPlanType& t);
    std::wstring ToString(const vcpkg::Dependencies::RequestType& t);
    std::wstring ToString(const vcpkg::PackageSpecParseResult& t);
    std::wstring ToString(const vcpkg::PackageSpec& t);
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
