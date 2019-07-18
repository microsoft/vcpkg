#include <vcpkg/statusparagraph.h>

#include <memory>

namespace vcpkg::Test {

std::unique_ptr<vcpkg::StatusParagraph> make_status_pgh(const char* name,
                                                        const char* depends = "",
                                                        const char* default_features = "",
                                                        const char* triplet = "x86-windows");

std::unique_ptr<vcpkg::StatusParagraph> make_status_feature_pgh(const char* name,
                                                                const char* feature,
                                                                const char* depends = "",
                                                                const char* triplet = "x86-windows");

vcpkg::PackageSpec unsafe_pspec(std::string name, vcpkg::Triplet t = vcpkg::Triplet::X86_WINDOWS);
}
