#include <catch2/catch.hpp>

#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>
#include <vcpkg/packagespec.h>

using namespace vcpkg;

TEST_CASE ("specifier conversion", "[specifier]")
{
    SECTION ("full package spec to feature specs")
    {
        constexpr std::size_t SPEC_SIZE = 6;

        PackageSpec a_spec("a", Triplet::X64_WINDOWS);
        PackageSpec b_spec("b", Triplet::X64_WINDOWS);

        auto fspecs = FullPackageSpec{a_spec, {"0", "1"}}.to_feature_specs({}, {});
        auto fspecs2 = FullPackageSpec{b_spec, {"2", "3"}}.to_feature_specs({}, {});
        Util::Vectors::append(&fspecs, fspecs2);
        Util::sort(fspecs);
        REQUIRE(fspecs.size() == SPEC_SIZE);

        std::array<const char*, SPEC_SIZE> features = {"0", "1", "core", "2", "3", "core"};
        std::array<PackageSpec*, SPEC_SIZE> specs = {&a_spec, &a_spec, &a_spec, &b_spec, &b_spec, &b_spec};

        for (std::size_t i = 0; i < SPEC_SIZE; ++i)
        {
            REQUIRE(features.at(i) == fspecs.at(i).feature());
            REQUIRE(*specs.at(i) == fspecs.at(i).spec());
        }
    }
}

TEST_CASE ("specifier parsing", "[specifier]")
{
    SECTION ("parsed specifier from string")
    {
        auto maybe_spec = vcpkg::parse_qualified_specifier("zlib");
        REQUIRE(maybe_spec.has_value());

        auto& spec = *maybe_spec.get();
        REQUIRE(spec.name == "zlib");
        REQUIRE(!spec.features);
        REQUIRE(!spec.triplet);
    }

    SECTION ("parsed specifier from string with triplet")
    {
        auto maybe_spec = vcpkg::parse_qualified_specifier("zlib:x64-uwp");
        REQUIRE(maybe_spec);

        auto& spec = *maybe_spec.get();
        REQUIRE(spec.name == "zlib");
        REQUIRE(spec.triplet.value_or("") == "x64-uwp");
    }

    SECTION ("parsed specifier from string with colons")
    {
        auto s = vcpkg::parse_qualified_specifier("zlib:x86-uwp:");
        REQUIRE(!s);
    }

    SECTION ("parsed specifier from string with feature")
    {
        auto maybe_spec = vcpkg::parse_qualified_specifier("zlib[feature]:x64-uwp");
        REQUIRE(maybe_spec);

        auto& spec = *maybe_spec.get();
        REQUIRE(spec.name == "zlib");
        REQUIRE(spec.features.value_or(std::vector<std::string>{}) == std::vector<std::string>{"feature"});
        REQUIRE(spec.triplet.value_or("") == "x64-uwp");
    }

    SECTION ("parsed specifier from string with many features")
    {
        auto maybe_spec = vcpkg::parse_qualified_specifier("zlib[0, 1,2]");
        REQUIRE(maybe_spec);

        auto& spec = *maybe_spec.get();
        REQUIRE(spec.features.value_or(std::vector<std::string>{}) == std::vector<std::string>{"0", "1", "2"});
    }

    SECTION ("parsed specifier wildcard feature")
    {
        auto maybe_spec = vcpkg::parse_qualified_specifier("zlib[*]");
        System::print2(maybe_spec.error());
        REQUIRE(maybe_spec);

        auto& spec = *maybe_spec.get();
        REQUIRE(spec.features.value_or(std::vector<std::string>{}) == std::vector<std::string>{"*"});
    }

    SECTION ("expand wildcards")
    {
        auto zlib = vcpkg::FullPackageSpec::from_string("zlib[0,1]", Triplet::X86_UWP).value_or_exit(VCPKG_LINE_INFO);
        auto openssl =
            vcpkg::FullPackageSpec::from_string("openssl[*]", Triplet::X86_UWP).value_or_exit(VCPKG_LINE_INFO);
        auto specs = zlib.to_feature_specs({}, {});
        auto specs2 = openssl.to_feature_specs({}, {});
        Util::Vectors::append(&specs, specs2);
        Util::sort(specs);

        std::vector<FeatureSpec> spectargets{
            {{"openssl", Triplet::X86_UWP}, "core"},
            {{"zlib", Triplet::X86_UWP}, "core"},
            {{"zlib", Triplet::X86_UWP}, "0"},
            {{"zlib", Triplet::X86_UWP}, "1"},
        };
        Util::sort(spectargets);
        REQUIRE(specs.size() == spectargets.size());
        REQUIRE(specs == spectargets);
    }

#if defined(_WIN32)
    SECTION ("ASCII to utf16")
    {
        auto str = vcpkg::Strings::to_utf16("abc");
        REQUIRE(str == L"abc");
    }

    SECTION ("ASCII to utf16 with whitespace")
    {
        auto str = vcpkg::Strings::to_utf16("abc -x86-windows");
        REQUIRE(str == L"abc -x86-windows");
    }
#endif
}
