#include <catch2/catch.hpp>
#include <vcpkg/pragmas.h>

#include <vcpkg/base/files.h>
#include <vcpkg/statusparagraph.h>

#include <memory>

#define CHECK_EC(ec)                                                                                                   \
    do                                                                                                                 \
    {                                                                                                                  \
        if (ec)                                                                                                        \
        {                                                                                                              \
            FAIL(ec.message());                                                                                        \
        }                                                                                                              \
    } while (0)

namespace vcpkg::Test
{
    std::unique_ptr<SourceControlFile> make_control_file(
        const char* name,
        const char* depends,
        const std::vector<std::pair<const char*, const char*>>& features = {},
        const std::vector<const char*>& default_features = {});

    std::unique_ptr<vcpkg::StatusParagraph> make_status_pgh(const char* name,
                                                            const char* depends = "",
                                                            const char* default_features = "",
                                                            const char* triplet = "x86-windows");

    std::unique_ptr<vcpkg::StatusParagraph> make_status_feature_pgh(const char* name,
                                                                    const char* feature,
                                                                    const char* depends = "",
                                                                    const char* triplet = "x86-windows");

    /// <summary>
    /// Map of source control files by their package name.
    /// </summary>
    struct PackageSpecMap
    {
        std::unordered_map<std::string, SourceControlFileLocation> map;
        Triplet triplet;
        PackageSpecMap(Triplet t = Triplet::X86_WINDOWS) noexcept : triplet(t) {}

        PackageSpec emplace(const char* name,
                            const char* depends = "",
                            const std::vector<std::pair<const char*, const char*>>& features = {},
                            const std::vector<const char*>& default_features = {});

        PackageSpec emplace(vcpkg::SourceControlFileLocation&& scfl);
    };

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

    struct AllowSymlinks
    {
        enum Tag : bool
        {
            No = false,
            Yes = true,
        } tag;

        constexpr AllowSymlinks(Tag tag) noexcept : tag(tag) {}

        constexpr explicit AllowSymlinks(bool b) noexcept : tag(b ? Yes : No) {}

        constexpr operator bool() const noexcept { return tag == Yes; }
    };

    AllowSymlinks can_create_symlinks() noexcept;

    const fs::path& base_temporary_directory() noexcept;

    void create_symlink(const fs::path& file, const fs::path& target, std::error_code& ec);

    void create_directory_symlink(const fs::path& file, const fs::path& target, std::error_code& ec);
}
