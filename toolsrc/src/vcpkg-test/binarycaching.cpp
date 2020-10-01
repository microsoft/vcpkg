#include <catch2/catch.hpp>

#include <vcpkg/base/files.h>

#include <vcpkg/binarycaching.h>
#include <vcpkg/binarycaching.private.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/sourceparagraph.h>
#include <vcpkg/vcpkgcmdarguments.h>

#include <string>

#include <vcpkg-test/util.h>

using namespace vcpkg;

#define REQUIRE_EQUAL_TEXT(lhs, rhs)                                                                                   \
    {                                                                                                                  \
        auto lhs_lines = Strings::split((lhs), '\n');                                                                  \
        auto rhs_lines = Strings::split((rhs), '\n');                                                                  \
        for (size_t i = 0; i < lhs_lines.size() && i < rhs_lines.size(); ++i)                                          \
        {                                                                                                              \
            INFO("on line: " << i);                                                                                    \
            REQUIRE(lhs_lines[i] == rhs_lines[i]);                                                                     \
        }                                                                                                              \
        REQUIRE(lhs_lines.size() == rhs_lines.size());                                                                 \
    }

TEST_CASE ("reformat_version semver-ish", "[reformat_version]")
{
    REQUIRE(reformat_version("0.0.0", "abitag") == "0.0.0-abitag");
    REQUIRE(reformat_version("1.0.1", "abitag") == "1.0.1-abitag");
    REQUIRE(reformat_version("1.01.000", "abitag") == "1.1.0-abitag");
    REQUIRE(reformat_version("1.2", "abitag") == "1.2.0-abitag");
    REQUIRE(reformat_version("v52", "abitag") == "52.0.0-abitag");
    REQUIRE(reformat_version("v09.01.02", "abitag") == "9.1.2-abitag");
    REQUIRE(reformat_version("1.1.1q", "abitag") == "1.1.1-abitag");
    REQUIRE(reformat_version("1", "abitag") == "1.0.0-abitag");
}

TEST_CASE ("reformat_version date", "[reformat_version]")
{
    REQUIRE(reformat_version("2020-06-26", "abitag") == "2020.6.26-abitag");
    REQUIRE(reformat_version("20-06-26", "abitag") == "0.0.0-abitag");
    REQUIRE(reformat_version("2020-06-26-release", "abitag") == "2020.6.26-abitag");
    REQUIRE(reformat_version("2020-06-26000", "abitag") == "2020.6.26-abitag");
}

TEST_CASE ("reformat_version generic", "[reformat_version]")
{
    REQUIRE(reformat_version("apr", "abitag") == "0.0.0-abitag");
    REQUIRE(reformat_version("", "abitag") == "0.0.0-abitag");
}

TEST_CASE ("generate_nuspec", "[generate_nuspec]")
{
    auto& fsWrapper = Files::get_real_filesystem();
    VcpkgCmdArguments args = VcpkgCmdArguments::create_from_arg_sequence(nullptr, nullptr);
    args.packages_root_dir = std::make_unique<std::string>("/");
    VcpkgPaths paths(fsWrapper, args);

    auto pghs = Paragraphs::parse_paragraphs(R"(
Source: zlib2
Version: 1.5
Build-Depends: zlib
Description: a spiffy compression library wrapper

Feature: a
Description: a feature

Feature: b
Description: enable bzip capabilities
Build-Depends: bzip
)",
                                             "<testdata>");
    REQUIRE(pghs.has_value());
    auto maybe_scf = SourceControlFile::parse_control_file(fs::path(), std::move(*pghs.get()));
    REQUIRE(maybe_scf.has_value());
    SourceControlFileLocation scfl{std::move(*maybe_scf.get()), fs::path()};

    Dependencies::InstallPlanAction ipa(PackageSpec{"zlib2", Test::X64_WINDOWS},
                                        scfl,
                                        Dependencies::RequestType::USER_REQUESTED,
                                        {{"a", {}}, {"b", {}}});

    ipa.abi_info = Build::AbiInfo{};
    ipa.abi_info.get()->package_abi = "packageabi";
    std::string tripletabi("tripletabi");
    ipa.abi_info.get()->triplet_abi = tripletabi;
    Build::CompilerInfo compiler_info;
    compiler_info.hash = "compilerhash";
    compiler_info.id = "compilerid";
    compiler_info.version = "compilerversion";
    ipa.abi_info.get()->compiler_info = compiler_info;

    NugetReference ref(ipa);

    REQUIRE(ref.nupkg_filename() == "zlib2_x64-windows.1.5.0-packageabi.nupkg");

    {
        auto nuspec = generate_nuspec(paths, ipa, ref, {});
#ifdef _WIN32
#define PKGPATH "C:\\zlib2_x64-windows\\**"
#else
#define PKGPATH "/zlib2_x64-windows/**"
#endif
        std::string expected = R"(<package>
  <metadata>
    <id>zlib2_x64-windows</id>
    <version>1.5.0-packageabi</version>
    <authors>vcpkg</authors>
    <description>NOT FOR DIRECT USE. Automatically generated cache package.

a spiffy compression library wrapper

Version: 1.5
Triplet: x64-windows
CXX Compiler id: compilerid
CXX Compiler version: compilerversion
Triplet/Compiler hash: tripletabi
Features: a, b
Dependencies:
</description>
    <packageTypes><packageType name="vcpkg"/></packageTypes>
  </metadata>
  <files><file src=")" PKGPATH R"(" target=""/></files>
</package>
)";
        REQUIRE_EQUAL_TEXT(nuspec, expected);
    }

    {
        auto nuspec = generate_nuspec(paths, ipa, ref, {"urlvalue"});
#ifdef _WIN32
#define PKGPATH "C:\\zlib2_x64-windows\\**"
#else
#define PKGPATH "/zlib2_x64-windows/**"
#endif
        std::string expected = R"(<package>
  <metadata>
    <id>zlib2_x64-windows</id>
    <version>1.5.0-packageabi</version>
    <authors>vcpkg</authors>
    <description>NOT FOR DIRECT USE. Automatically generated cache package.

a spiffy compression library wrapper

Version: 1.5
Triplet: x64-windows
CXX Compiler id: compilerid
CXX Compiler version: compilerversion
Triplet/Compiler hash: tripletabi
Features: a, b
Dependencies:
</description>
    <packageTypes><packageType name="vcpkg"/></packageTypes>
    <repository type="git" url="urlvalue"/>
  </metadata>
  <files><file src=")" PKGPATH R"(" target=""/></files>
</package>
)";
        REQUIRE_EQUAL_TEXT(nuspec, expected);
    }
    {
        auto nuspec = generate_nuspec(paths, ipa, ref, {"urlvalue", "branchvalue", "commitvalue"});
#ifdef _WIN32
#define PKGPATH "C:\\zlib2_x64-windows\\**"
#else
#define PKGPATH "/zlib2_x64-windows/**"
#endif
        std::string expected = R"(<package>
  <metadata>
    <id>zlib2_x64-windows</id>
    <version>1.5.0-packageabi</version>
    <authors>vcpkg</authors>
    <description>NOT FOR DIRECT USE. Automatically generated cache package.

a spiffy compression library wrapper

Version: 1.5
Triplet: x64-windows
CXX Compiler id: compilerid
CXX Compiler version: compilerversion
Triplet/Compiler hash: tripletabi
Features: a, b
Dependencies:
</description>
    <packageTypes><packageType name="vcpkg"/></packageTypes>
    <repository type="git" url="urlvalue" branch="branchvalue" commit="commitvalue"/>
  </metadata>
  <files><file src=")" PKGPATH R"(" target=""/></files>
</package>
)";
        REQUIRE_EQUAL_TEXT(nuspec, expected);
    }
}

TEST_CASE ("XmlSerializer", "[XmlSerializer]")
{
    XmlSerializer xml;
    xml.open_tag("a");
    xml.open_tag("b");
    xml.simple_tag("c", "d");
    xml.close_tag("b");
    xml.text("escaping: & < > \" '");

    REQUIRE(xml.buf == R"(<a><b><c>d</c></b>escaping: &amp; &lt; &gt; &quot; &apos;)");

    xml = XmlSerializer();
    xml.emit_declaration();
    xml.start_complex_open_tag("a")
        .text_attr("b", "<")
        .text_attr("c", "  ")
        .finish_self_closing_complex_tag()
        .line_break();
    xml.simple_tag("d", "e");
    REQUIRE(xml.buf == R"(<?xml version="1.0" encoding="utf-8"?><a b="&lt;" c="  "/>)"
                       "\n<d>e</d>");

    xml = XmlSerializer();
    xml.start_complex_open_tag("a").finish_complex_open_tag();
    REQUIRE(xml.buf == R"(<a>)");

    xml = XmlSerializer();
    xml.line_break();
    xml.open_tag("a").line_break().line_break();
    xml.close_tag("a").line_break().line_break();
    REQUIRE(xml.buf == "\n<a>\n\n</a>\n\n");

    xml = XmlSerializer();
    xml.start_complex_open_tag("a")
        .text_attr("b", "<")
        .line_break()
        .text_attr("c", "  ")
        .finish_complex_open_tag()
        .line_break();
    xml.simple_tag("d", "e").line_break();
    REQUIRE(xml.buf == "<a b=\"&lt;\"\n  c=\"  \">\n  <d>e</d>\n");
}

TEST_CASE ("generate_nuget_packages_config", "[generate_nuget_packages_config]")
{
    Dependencies::ActionPlan plan;
    auto packageconfig = generate_nuget_packages_config(plan);
    REQUIRE(packageconfig == R"(<?xml version="1.0" encoding="utf-8"?>
<packages>
</packages>
)");

    auto pghs = Paragraphs::parse_paragraphs(R"(
Source: zlib
Version: 1.5
Description: a spiffy compression library wrapper
)",
                                             "<testdata>");
    REQUIRE(pghs.has_value());
    auto maybe_scf = SourceControlFile::parse_control_file(fs::path(), std::move(*pghs.get()));
    REQUIRE(maybe_scf.has_value());
    SourceControlFileLocation scfl{std::move(*maybe_scf.get()), fs::path()};
    plan.install_actions.push_back(Dependencies::InstallPlanAction());
    plan.install_actions[0].spec = PackageSpec("zlib", Test::X64_ANDROID);
    plan.install_actions[0].source_control_file_location = scfl;
    plan.install_actions[0].abi_info = Build::AbiInfo{};
    plan.install_actions[0].abi_info.get()->package_abi = "packageabi";

    packageconfig = generate_nuget_packages_config(plan);
    REQUIRE(packageconfig == R"(<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="zlib_x64-android" version="1.5.0-packageabi"/>
</packages>
)");

    auto pghs2 = Paragraphs::parse_paragraphs(R"(
Source: zlib2
Version: 1.52
Description: a spiffy compression library wrapper
)",
                                              "<testdata>");
    REQUIRE(pghs2.has_value());
    auto maybe_scf2 = SourceControlFile::parse_control_file(fs::path(), std::move(*pghs2.get()));
    REQUIRE(maybe_scf2.has_value());
    SourceControlFileLocation scfl2{std::move(*maybe_scf2.get()), fs::path()};
    plan.install_actions.push_back(Dependencies::InstallPlanAction());
    plan.install_actions[1].spec = PackageSpec("zlib2", Test::X64_ANDROID);
    plan.install_actions[1].source_control_file_location = scfl2;
    plan.install_actions[1].abi_info = Build::AbiInfo{};
    plan.install_actions[1].abi_info.get()->package_abi = "packageabi2";

    packageconfig = generate_nuget_packages_config(plan);
    REQUIRE(packageconfig == R"(<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="zlib_x64-android" version="1.5.0-packageabi"/>
  <package id="zlib2_x64-android" version="1.52.0-packageabi2"/>
</packages>
)");
}
