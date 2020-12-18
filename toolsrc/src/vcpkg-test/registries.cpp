#include <catch2/catch.hpp>

#include <vcpkg/registries.h>

using namespace vcpkg;

namespace
{
    struct TestRegistryImplementation final : RegistryImplementation
    {
        std::unique_ptr<RegistryEntry> get_port_entry(const VcpkgPaths&, StringView) const override { return nullptr; }

        void get_all_port_names(std::vector<std::string>&, const VcpkgPaths&) const override { }

        Optional<VersionT> get_baseline_version(const VcpkgPaths&, StringView) const override { return nullopt; }

        int number;

        TestRegistryImplementation(int n) : number(n) {}
    };

    Registry make_registry(int n, std::vector<std::string>&& port_names)
    {
        return {std::move(port_names), std::make_unique<TestRegistryImplementation>(n)};
    }

    int get_tri_num(const RegistryImplementation& r)
    {
        if (auto tri = dynamic_cast<const TestRegistryImplementation*>(&r))
        {
            return tri->number;
        }
        else
        {
            return -1;
        }
        
    }

}

TEST_CASE ("registry_set_selects_registry", "[registries]")
{
    RegistrySet set;
    set.set_default_registry(std::make_unique<TestRegistryImplementation>(0));

    set.add_registry(make_registry(1, {"p1", "q1", "r1"}));
    set.add_registry(make_registry(2, {"p2", "q2", "r2"}));

    auto reg = set.registry_for_port("p1");
    REQUIRE(reg);
    CHECK(get_tri_num(*reg) == 1);
    reg = set.registry_for_port("r2");
    REQUIRE(reg);
    CHECK(get_tri_num(*reg) == 2);
    reg = set.registry_for_port("a");
    REQUIRE(reg);
    CHECK(get_tri_num(*reg) == 0);

    set.set_default_registry(nullptr);

    reg = set.registry_for_port("q1");
    REQUIRE(reg);
    CHECK(get_tri_num(*reg) == 1);
    reg = set.registry_for_port("p2");
    REQUIRE(reg);
    CHECK(get_tri_num(*reg) == 2);
    reg = set.registry_for_port("a");
    CHECK_FALSE(reg);
}
