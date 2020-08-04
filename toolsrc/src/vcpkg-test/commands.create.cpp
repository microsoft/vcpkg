#include <catch2/catch.hpp>

#include <vcpkg/base/files.h>

#include <vcpkg/commands.create.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

#include <iterator>
#include <string>

TEST_CASE ("create smoke test", "[commands-create]")
{
    using namespace vcpkg;
    static const std::string argsRaw[] = {"create", "zlib2", "http://zlib.net/zlib-1.2.11.tar.gz", "zlib-1.2.11.zip"};

    auto& fsWrapper = Files::get_real_filesystem();
    VcpkgCmdArguments args = VcpkgCmdArguments::create_from_arg_sequence(std::begin(argsRaw), std::end(argsRaw));
    VcpkgPaths paths(fsWrapper, args);
    const auto exit_code = Commands::Create::perform(args, paths);
    REQUIRE(exit_code == 0);
    const auto expected_port = paths.ports / fs::u8path("zlib2");
    const auto expected_portfile_cmake = expected_port / fs::u8path("portfile.cmake");
    const auto lines = fsWrapper.read_lines(expected_portfile_cmake);
    REQUIRE(lines.has_value());
    fsWrapper.remove_all(expected_port, ignore_errors);
}
