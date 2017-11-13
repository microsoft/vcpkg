#pragma once

#include <CppUnitTest.h>

#include <vcpkg/dependencies.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/packagespecparseresult.h>
#include <vcpkg/statusparagraph.h>

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
                                                        const char* triplet = "x86-windows");
std::unique_ptr<vcpkg::StatusParagraph> make_status_feature_pgh(const char* name,
                                                                const char* feature,
                                                                const char* depends = "",
                                                                const char* triplet = "x86-windows");