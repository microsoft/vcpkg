#include <catch2/catch.hpp>

#include <string>
#include <iterator>
#include <vcpkg/base/files.h>
#include <vcpkg/commands.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

TEST_CASE ("build smoke test", "[commands-build]")
{
    using namespace vcpkg;
    static const std::string args_raw[] = {"build", "zlib"};

    auto& fs_wrapper = Files::get_real_filesystem();
    VcpkgCmdArguments args = VcpkgCmdArguments::create_from_arg_sequence(std::begin(args_raw), std::end(args_raw));
    VcpkgPaths paths(fs_wrapper, args);
    auto triplet = default_triplet(args);
    const auto exit_code = Build::Command::perform(args, paths, triplet);
    REQUIRE(exit_code == 0);
    REQUIRE(paths.get_filesystem().is_directory(paths.buildtrees / fs::u8path("zlib")));
}
