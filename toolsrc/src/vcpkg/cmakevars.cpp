#include "pch.h"

#include <vcpkg/base/optional.h>
#include <vcpkg/base/span.h>
#include <vcpkg/base/util.h>

#include <vcpkg/cmakevars.h>

using namespace vcpkg;
using vcpkg::Optional;
using vcpkg::CMakeVars::TripletCMakeVarProvider;

namespace vcpkg::CMakeVars
{
    fs::path TripletCMakeVarProvider::create_tag_extraction_file(
        const Span<const std::pair<const FullPackageSpec*, std::string>>& spec_abi_settings) const
    {
        constexpr StringLiteral COMMAND_START = "vcpkg_get_tags(";
        constexpr StringLiteral COMMAND_END = ")\n";
        constexpr size_t COMMAND_LENGTH = COMMAND_START.size() + COMMAND_END.size();

        std::vector<std::string> feature_lists(spec_abi_settings.size());

        std::unique_ptr<Hash::Hasher> hasher = Hash::get_hasher_for(Hash::Algorithm::Sha1);

        size_t parameter_chars = 0;
        for (const auto& spec_abi_setting : spec_abi_settings)
        {
            const FullPackageSpec& spec = *spec_abi_setting.first;

            parameter_chars += spec.package_spec.name().size();
            feature_lists.emplace_back(Strings::join(";", spec.features));
            parameter_chars += feature_lists.back().size();
            parameter_chars += paths.get_triplet_file_path(spec.package_spec.triplet()).u8string().size();
            parameter_chars += spec_abi_setting.second.size();
        }

        const size_t space_quote_chars = spec_abi_settings.size() * 11;

        std::string extraction_file("include(" + get_tags_path.u8string() + ")\n\n");
        extraction_file.reserve(extraction_file.length() + COMMAND_LENGTH + parameter_chars + space_quote_chars);

        auto feature_list_itr = feature_lists.cbegin();
        for (const auto& spec_abi_setting : spec_abi_settings)
        {
            const FullPackageSpec& spec = *spec_abi_setting.first;

            hasher->add_bytes(spec.package_spec.name().c_str(),
                              spec.package_spec.name().c_str() + spec.package_spec.name().length());
            hasher->add_bytes(spec.package_spec.triplet().to_string().c_str(),
                              spec.package_spec.triplet().to_string().c_str() +
                                  spec.package_spec.triplet().to_string().length());

            Strings::append(extraction_file,
                            COMMAND_START,
                            "\"",
                            spec.package_spec.name(),
                            "\" \"",
                            *feature_list_itr,
                            "\" \"",
                            paths.get_triplet_file_path(spec.package_spec.triplet()).u8string(),
                            "\" \"",
                            spec_abi_setting.second,
                            "\"",
                            COMMAND_END);

            ++feature_list_itr;
        }

        fs::path path = paths.buildtrees / (hasher->get_hash() + ".vcpkg_tags.cmake");

        Files::Filesystem& fs = paths.get_filesystem();

        std::error_code ec;
        fs.create_directories(paths.buildtrees, ec);
        Checks::check_exit(VCPKG_LINE_INFO, !ec, "Could not create directory %s", paths.buildtrees.u8string());
        fs.write_contents(path, extraction_file, VCPKG_LINE_INFO);

        return path;
    }

    fs::path TripletCMakeVarProvider::create_dep_info_extraction_file(const Span<const PackageSpec> specs) const
    {
        constexpr StringLiteral COMMAND_START = "vcpkg_get_dep_info(";
        constexpr StringLiteral COMMAND_END = ")\n";
        constexpr size_t COMMAND_LENGTH = COMMAND_START.size() + COMMAND_END.size();

        std::unique_ptr<Hash::Hasher> hasher = Hash::get_hasher_for(Hash::Algorithm::Sha1);
        hasher->clear();

        size_t parameter_chars = 0;
        for (const PackageSpec& spec : specs)
        {
            parameter_chars += spec.name().size();
            parameter_chars += paths.get_triplet_file_path(spec.triplet()).u8string().size();
        }

        const size_t space_chars = specs.size();

        std::string extraction_file("include(" + get_dep_info_path.u8string() + ")\n\n");

        extraction_file.reserve(extraction_file.length() + COMMAND_LENGTH + parameter_chars + space_chars);

        for (const PackageSpec& spec : specs)
        {
            hasher->add_bytes(spec.name().c_str(), spec.name().c_str() + spec.name().length());
            hasher->add_bytes(spec.triplet().to_string().c_str(),
                              spec.triplet().to_string().c_str() + spec.triplet().to_string().length());

            Strings::append(extraction_file,
                            COMMAND_START,
                            spec.name(),
                            " ",
                            paths.get_triplet_file_path(spec.triplet()).u8string(),
                            COMMAND_END);
        }

        fs::path path = paths.buildtrees / (hasher->get_hash() + ".vcpkg_dep_info.cmake");

        Files::Filesystem& fs = paths.get_filesystem();

        std::error_code ec;
        fs.create_directories(paths.buildtrees, ec);
        Checks::check_exit(VCPKG_LINE_INFO, !ec, "Could not create directory %s", paths.buildtrees.u8string());
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

        const auto cmd_launch_cmake = System::make_cmake_cmd(cmake_exe_path, script_path, {});
        const auto ec_data = System::cmd_execute_and_capture_output(cmd_launch_cmake);
        Checks::check_exit(VCPKG_LINE_INFO, ec_data.exit_code == 0, ec_data.output);

        const std::vector<std::string> lines = Strings::split(ec_data.output, "\n");

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

                    std::vector<std::string> s = Strings::split(line, "=");
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

    void TripletCMakeVarProvider::load_generic_triplet_vars(const Triplet& triplet) const
    {
        std::vector<std::vector<std::pair<std::string, std::string>>> vars(1);
        FullPackageSpec full_spec = FullPackageSpec::from_string("", triplet).value_or_exit(VCPKG_LINE_INFO);
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
            spec_abi_settings.emplace_back(&spec, override_path.u8string());
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
        const Triplet& triplet) const
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
