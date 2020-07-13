#include <catch2/catch.hpp>

#include <vcpkg/base/files.h>

#include <vcpkg/commands.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

#include <iterator>
#include <string>

#include <vcpkg-test/util.h>

using namespace vcpkg;

TEST_CASE ("build smoke test", "[commands-build]")
{
    static const std::string args_raw[] = {"build", "zlib"};

    auto& fs_wrapper = Files::get_real_filesystem();
    VcpkgCmdArguments args = VcpkgCmdArguments::create_from_arg_sequence(std::begin(args_raw), std::end(args_raw));
    args.binary_caching = false;
    args.buildtrees_root_dir =
        std::make_unique<std::string>((Test::base_temporary_directory() / fs::u8path("buildtrees")).u8string());
    args.install_root_dir =
        std::make_unique<std::string>((Test::base_temporary_directory() / fs::u8path("installed")).u8string());
    args.packages_root_dir =
        std::make_unique<std::string>((Test::base_temporary_directory() / fs::u8path("packages")).u8string());
    VcpkgPaths paths(fs_wrapper, args);
    if (fs_wrapper.exists(paths.buildtrees)) fs_wrapper.remove_all_inside(paths.buildtrees, VCPKG_LINE_INFO);
    if (fs_wrapper.exists(paths.packages)) fs_wrapper.remove_all_inside(paths.packages, VCPKG_LINE_INFO);
    if (fs_wrapper.exists(paths.installed)) fs_wrapper.remove_all_inside(paths.installed, VCPKG_LINE_INFO);
    auto triplet = default_triplet(args);
    const auto exit_code = Build::Command::perform(args, paths, triplet);
    REQUIRE(exit_code == 0);
    REQUIRE(paths.get_filesystem().is_directory(paths.buildtrees / fs::u8path("zlib")));
}
