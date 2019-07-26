#include <vcpkg/base/files.h>
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

template<class T, class S>
T&& unwrap(vcpkg::ExpectedT<T, S>&& p)
{
    REQUIRE(p.has_value());
    return std::move(*p.get());
}

template<class T>
T&& unwrap(vcpkg::Optional<T>&& opt)
{
    REQUIRE(opt.has_value());
    return std::move(*opt.get());
}

extern const bool SYMLINKS_ALLOWED;

extern const fs::path TEMPORARY_DIRECTORY;

void create_symlink(const fs::path& file, const fs::path& target, std::error_code& ec);

void create_directory_symlink(const fs::path& file, const fs::path& target, std::error_code& ec);

}
