#include "pch.h"

#include <vcpkg/base/hash.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/span.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#include <vcpkg/buildenvironment.h>
#include <vcpkg/cmakevars.h>
#include <vcpkg/dependencies.h>

using namespace vcpkg;
using vcpkg::Optional;

namespace vcpkg::CMakeVars
{
    void CMakeVarProvider::load_tag_vars(const vcpkg::Dependencies::ActionPlan& action_plan,
                                         const PortFileProvider::PortFileProvider& port_provider) const
    {
        std::vector<FullPackageSpec> install_package_specs;
        for (auto&& action : action_plan.install_actions)
        {
            install_package_specs.emplace_back(FullPackageSpec{action.spec, action.feature_list});
        }

        load_tag_vars(install_package_specs, port_provider);
    }

    namespace
    {
        struct TripletCMakeVarProvider : Util::ResourceBase, CMakeVarProvider
        {
            explicit TripletCMakeVarProvider(const vcpkg::VcpkgPaths& paths) : paths(paths) { }

            void load_generic_triplet_vars(Triplet triplet) const override;

            void load_dep_info_vars(Span<const PackageSpec> specs) const override;

            void load_tag_vars(Span<const FullPackageSpec> specs,
                               const PortFileProvider::PortFileProvider& port_provider) const override;

            Optional<const std::unordered_map<std::string, std::string>&> get_generic_triplet_vars(
                Triplet triplet) const override;

            Optional<const std::unordered_map<std::string, std::string>&> get_dep_info_vars(
                const PackageSpec& spec) const override;

            Optional<const std::unordered_map<std::string, std::string>&> get_tag_vars(
                const PackageSpec& spec) const override;

        public:
            fs::path create_tag_extraction_file(
                const Span<const std::pair<const FullPackageSpec*, std::string>>& spec_abi_settings) const;

            fs::path create_dep_info_extraction_file(const Span<const PackageSpec> specs) const;

            void launch_and_split(const fs::path& script_path,
                                  std::vector<std::vector<std::pair<std::string, std::string>>>& vars) const;

            const VcpkgPaths& paths;
            const fs::path get_tags_path = paths.scripts / "vcpkg_get_tags.cmake";
            const fs::path get_dep_info_path = paths.scripts / "vcpkg_get_dep_info.cmake";
            mutable std::unordered_map<PackageSpec, std::unordered_map<std::string, std::string>> dep_resolution_vars;
            mutable std::unordered_map<PackageSpec, std::unordered_map<std::string, std::string>> tag_vars;
            mutable std::unordered_map<Triplet, std::unordered_map<std::string, std::string>> generic_triplet_vars;
        };
    }

    std::unique_ptr<CMakeVarProvider> make_triplet_cmake_var_provider(const vcpkg::VcpkgPaths& paths)
    {
        return std::make_unique<TripletCMakeVarProvider>(paths);
    }

    fs::path TripletCMakeVarProvider::create_tag_extraction_file(
        const Span<const std::pair<const FullPackageSpec*, std::string>>& spec_abi_settings) const
    {
        Files::Filesystem& fs = paths.get_filesystem();
        static int tag_extract_id = 0;

        std::string extraction_file("include(\"" + get_tags_path.generic_u8string() + "\")\n\n");

        std::map<Triplet, int> emitted_triplets;
        int emitted_triplet_id = 0;
        for (const auto& spec_abi_setting : spec_abi_settings)
        {
            emitted_triplets[spec_abi_setting.first->package_spec.triplet()] = emitted_triplet_id++;
        }
        Strings::append(extraction_file, "macro(vcpkg_triplet_file VCPKG_TRIPLET_ID)\n");
        for (auto& p : emitted_triplets)
        {
            Strings::append(extraction_file,
                            "if(VCPKG_TRIPLET_ID EQUAL ",
                            p.second,
                            ")\n",
                            fs.read_contents(paths.get_triplet_file_path(p.first), VCPKG_LINE_INFO),
                            "\nendif()\n");
        }
        Strings::append(extraction_file, "endmacro()\n");
        for (const auto& spec_abi_setting : spec_abi_settings)
        {
            const FullPackageSpec& spec = *spec_abi_setting.first;

            Strings::append(extraction_file,
                            "vcpkg_get_tags(\"",
                            spec.package_spec.name(),
                            "\" \"",
                            Strings::join(";", spec.features),
                            "\" \"",
                            emitted_triplets[spec.package_spec.triplet()],
                            "\" \"",
                            spec_abi_setting.second,
                            "\")\n");
        }

        fs::path path = paths.buildtrees / Strings::concat(tag_extract_id++, ".vcpkg_tags.cmake");

        fs.create_directories(paths.buildtrees, ignore_errors);
        fs.write_contents(path, extraction_file, VCPKG_LINE_INFO);

        return path;
    }

    fs::path TripletCMakeVarProvider::create_dep_info_extraction_file(const Span<const PackageSpec> specs) const
    {
        static int dep_info_id = 0;
        Files::Filesystem& fs = paths.get_filesystem();

        std::string extraction_file("include(\"" + get_dep_info_path.generic_u8string() + "\")\n\n");

        std::map<Triplet, int> emitted_triplets;
        int emitted_triplet_id = 0;
        for (const auto& spec : specs)
        {
            emitted_triplets[spec.triplet()] = emitted_triplet_id++;
        }
        Strings::append(extraction_file, "macro(vcpkg_triplet_file VCPKG_TRIPLET_ID)\n");
        for (auto& p : emitted_triplets)
        {
            Strings::append(extraction_file,
                            "if(VCPKG_TRIPLET_ID EQUAL ",
                            p.second,
                            ")\n",
                            fs.read_contents(paths.get_triplet_file_path(p.first), VCPKG_LINE_INFO),
                            "\nendif()\n");
        }
        Strings::append(extraction_file, "endmacro()\n");

        for (const PackageSpec& spec : specs)
        {
            Strings::append(
                extraction_file, "vcpkg_get_dep_info(", spec.name(), " ", emitted_triplets[spec.triplet()], ")\n");
        }

        fs::path path = paths.buildtrees / Strings::concat(dep_info_id++, ".vcpkg_dep_info.cmake");

        std::error_code ec;
        fs.create_directories(paths.buildtrees, ec);
        fs.write_contents(path, extraction_file, VCPKG_LINE_INFO);

        return path;
    }

    void TripletCMakeVarProvider::launch_and_split(
        const fs::path& script_path, std::vector<std::vector<std::pair<std::string, std::string>>>& vars) const
    {
        static constexpr CStringView PORT_START_GUID = "d8187afd-ea4a-4fc3-9aa4-a6782e1ed9af";
        static constexpr CStringView PORT_END_GUID = "8c504940-be29-4cba-9f8f-6cd83e9d87b7";
        static constexpr CStringView BLOCK_START_GUID = "c35112b6-d1ba-415b-aa5d-81de856ef8eb";
        static constexpr CStringView BLOCK_END_GUID = "e1e74b5c-18cb-4474-a6bd-5c1c8bc81f3f";

        const auto cmd_launch_cmake = vcpkg::make_cmake_cmd(paths, script_path, {});
        const auto ec_data = System::cmd_execute_and_capture_output(cmd_launch_cmake);
        Checks::check_exit(VCPKG_LINE_INFO, ec_data.exit_code == 0, ec_data.output);

        const std::vector<std::string> lines = Strings::split(ec_data.output, '\n');

        const auto end = lines.cend();

        auto port_start = std::find(lines.cbegin(), end, PORT_START_GUID);
        auto port_end = std::find(port_start, end, PORT_END_GUID);

        for (auto var_itr = vars.begin(); port_start != end && var_itr != vars.end(); ++var_itr)
        {
            auto block_start = std::find(port_start, port_end, BLOCK_START_GUID);
            auto block_end = std::find(++block_start, port_end, BLOCK_END_GUID);

            while (block_start != port_end)
            {
                while (block_start != block_end)
                {
                    const std::string& line = *block_start;

                    std::vector<std::string> s = Strings::split(line, '=');
                    Checks::check_exit(VCPKG_LINE_INFO,
                                       s.size() == 1 || s.size() == 2,
                                       "Expected format is [VARIABLE_NAME=VARIABLE_VALUE], but was [%s]",
                                       line);

                    var_itr->emplace_back(std::move(s[0]), s.size() == 1 ? "" : std::move(s[1]));

                    ++block_start;
                }

                block_start = std::find(block_end, port_end, BLOCK_START_GUID);
                block_end = std::find(block_start, port_end, BLOCK_END_GUID);
            }

            port_start = std::find(port_end, end, PORT_START_GUID);
            port_end = std::find(port_start, end, PORT_END_GUID);
        }
    }

    void TripletCMakeVarProvider::load_generic_triplet_vars(Triplet triplet) const
    {
        std::vector<std::vector<std::pair<std::string, std::string>>> vars(1);
        // Hack: PackageSpecs should never have .name==""
        FullPackageSpec full_spec({"", triplet});
        const fs::path file_path =
            create_tag_extraction_file(std::array<std::pair<const FullPackageSpec*, std::string>, 1>{
                std::pair<const FullPackageSpec*, std::string>{&full_spec, ""}});
        launch_and_split(file_path, vars);
        paths.get_filesystem().remove(file_path, VCPKG_LINE_INFO);

        generic_triplet_vars[triplet].insert(std::make_move_iterator(vars.front().begin()),
                                             std::make_move_iterator(vars.front().end()));
    }

    void TripletCMakeVarProvider::load_dep_info_vars(Span<const PackageSpec> specs) const
    {
        if (specs.size() == 0) return;
        std::vector<std::vector<std::pair<std::string, std::string>>> vars(specs.size());
        const fs::path file_path = create_dep_info_extraction_file(specs);
        if (specs.size() > 100)
        {
            System::print2("Loading dependency information for ", specs.size(), " packages...\n");
        }
        launch_and_split(file_path, vars);
        paths.get_filesystem().remove(file_path, VCPKG_LINE_INFO);

        auto var_list_itr = vars.begin();
        for (const PackageSpec& spec : specs)
        {
            dep_resolution_vars.emplace(std::piecewise_construct,
                                        std::forward_as_tuple(spec),
                                        std::forward_as_tuple(std::make_move_iterator(var_list_itr->begin()),
                                                              std::make_move_iterator(var_list_itr->end())));
            ++var_list_itr;
        }
    }

    void TripletCMakeVarProvider::load_tag_vars(Span<const FullPackageSpec> specs,
                                                const PortFileProvider::PortFileProvider& port_provider) const
    {
        if (specs.size() == 0) return;
        std::vector<std::pair<const FullPackageSpec*, std::string>> spec_abi_settings;
        spec_abi_settings.reserve(specs.size());

        for (const FullPackageSpec& spec : specs)
        {
            auto& scfl = port_provider.get_control_file(spec.package_spec.name()).value_or_exit(VCPKG_LINE_INFO);
            const fs::path override_path = scfl.source_location / "vcpkg-abi-settings.cmake";
            spec_abi_settings.emplace_back(&spec, override_path.generic_u8string());
        }

        std::vector<std::vector<std::pair<std::string, std::string>>> vars(spec_abi_settings.size());
        const fs::path file_path = create_tag_extraction_file(spec_abi_settings);
        launch_and_split(file_path, vars);
        paths.get_filesystem().remove(file_path, VCPKG_LINE_INFO);

        auto var_list_itr = vars.begin();
        for (const auto& spec_abi_setting : spec_abi_settings)
        {
            const FullPackageSpec& spec = *spec_abi_setting.first;

            tag_vars.emplace(std::piecewise_construct,
                             std::forward_as_tuple(spec.package_spec),
                             std::forward_as_tuple(std::make_move_iterator(var_list_itr->begin()),
                                                   std::make_move_iterator(var_list_itr->end())));
            ++var_list_itr;
        }
    }

    Optional<const std::unordered_map<std::string, std::string>&> TripletCMakeVarProvider::get_generic_triplet_vars(
        Triplet triplet) const
    {
        auto find_itr = generic_triplet_vars.find(triplet);
        if (find_itr != generic_triplet_vars.end())
        {
            return find_itr->second;
        }

        return nullopt;
    }

    Optional<const std::unordered_map<std::string, std::string>&> TripletCMakeVarProvider::get_dep_info_vars(
        const PackageSpec& spec) const
    {
        auto find_itr = dep_resolution_vars.find(spec);
        if (find_itr != dep_resolution_vars.end())
        {
            return find_itr->second;
        }

        return nullopt;
    }

    Optional<const std::unordered_map<std::string, std::string>&> TripletCMakeVarProvider::get_tag_vars(
        const PackageSpec& spec) const
    {
        auto find_itr = tag_vars.find(spec);
        if (find_itr != tag_vars.end())
        {
            return find_itr->second;
        }

        return nullopt;
    }
}
