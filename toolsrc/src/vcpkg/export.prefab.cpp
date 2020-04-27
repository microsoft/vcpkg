#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/build.h>
#include <vcpkg/cmakevars.h>
#include <vcpkg/commands.h>
#include <vcpkg/export.h>
#include <vcpkg/export.prefab.h>
#include <vcpkg/install.h>

namespace vcpkg::Export::Prefab
{
    using Dependencies::ExportPlanAction;
    using Dependencies::ExportPlanType;
    using Install::InstallDir;
    using System::CPUArchitecture;

    static std::vector<fs::path> find_modules(const VcpkgPaths& system, const fs::path& root, const std::string& ext)
    {
        std::vector<fs::path> paths;
        Files::Filesystem& utils = system.get_filesystem();
        std::error_code error_code;
        if (!utils.exists(root, error_code) || !utils.is_directory(root)) return paths;

        fs::stdfs::recursive_directory_iterator it(root);
        fs::stdfs::recursive_directory_iterator endit;

        while (it != endit)
        {
            if (utils.is_regular_file(*it) && it->path().extension() == ext)
            {
                paths.push_back(it->path().filename());
            }
            ++it;
        }
        return paths;
    }

    std::string NdkVersion::to_string()
    {
        std::string ret;
        this->to_string(ret);
        return ret;
    }
    void NdkVersion::to_string(std::string& out)
    {
        out.append("NdkVersion{major=")
            .append(std::to_string(major()))
            .append(",minor=")
            .append(std::to_string(minor()))
            .append(",patch=")
            .append(std::to_string(patch()))
            .append("}");
    }

    static std::string jsonify(const std::vector<std::string>& dependencies)
    {
        std::vector<std::string> deps;
        for (const auto& dep : dependencies)
        {
            deps.push_back("\"" + dep + "\"");
        }
        return Strings::join(",", deps);
    }

    static std::string null_if_empty(const std::string& str)
    {
        std::string copy = str;
        if (copy.size() == 0)
        {
            copy = "null";
        }
        else
        {
            copy = "\"" + copy + "\"";
        }
        return copy;
    }

    static std::string null_if_empty_array(const std::string& str)
    {
        std::string copy = str;
        if (copy.size() == 0)
        {
            copy = "null";
        }
        else
        {
            copy = "[" + copy + "]";
        }
        return copy;
    }

    std::string ABIMetadata::to_string()
    {
        std::string TEMPLATE = R"({
    "abi":"@ABI@",
    "api":@API@,
    "ndk":@NDK@,
    "stl":"@STL@"
})";
        std::string json = Strings::replace_all(std::move(TEMPLATE), "@ABI@", abi);
        json = Strings::replace_all(std::move(json), "@API@", std::to_string(api));
        json = Strings::replace_all(std::move(json), "@NDK@", std::to_string(ndk));
        json = Strings::replace_all(std::move(json), "@STL@", stl);
        return json;
    }

    std::string PlatformModuleMetadata::to_json()
    {
        std::string TEMPLATE = R"({
    "export_libraries": @LIBRARIES@,
    "library_name": @LIBRARY_NAME@
})";

        std::string json = Strings::replace_all(std::move(TEMPLATE), "@LIBRARY_NAME@", null_if_empty(library_name));
        json = Strings::replace_all(std::move(json), "@LIBRARIES@", null_if_empty_array(jsonify(export_libraries)));
        return json;
    }

    std::string ModuleMetadata::to_json()
    {
        std::string TEMPLATE = R"({
    "export_libraries": [@LIBRARIES@],
    "library_name":@LIBRARY_NAME@,
    "android": @ANDROID_METADATA@
})";

        std::string json = Strings::replace_all(std::move(TEMPLATE), "@LIBRARY_NAME@", null_if_empty(library_name));
        json = Strings::replace_all(std::move(json), "@LIBRARIES@", jsonify(export_libraries));
        json = Strings::replace_all(std::move(json), "@ANDROID_METADATA@", android.to_json());
        return json;
    }

    std::string PackageMetadata::to_json()
    {
        std::string deps = jsonify(dependencies);

        std::string TEMPLATE = R"({
    "name":"@PACKAGE_NAME@",
    "schema_version": @PACKAGE_SCHEMA@,
    "dependencies":[@PACKAGE_DEPS@],
    "version":"@PACKAGE_VERSION@"
})";
        std::string json = Strings::replace_all(std::move(TEMPLATE), "@PACKAGE_NAME@", name);
        json = Strings::replace_all(std::move(json), "@PACKAGE_SCHEMA@", std::to_string(schema));
        json = Strings::replace_all(std::move(json), "@PACKAGE_DEPS@", deps);
        json = Strings::replace_all(std::move(json), "@PACKAGE_VERSION@", version);
        return json;
    }

    Optional<std::string> find_ndk_version(const std::string& content)
    {
        std::smatch pkg_match;
        std::regex pkg_regex(R"(Pkg\.Revision\s*=\s*(\d+)(\.\d+)(\.\d+)\s*)");

        if (std::regex_search(content, pkg_match, pkg_regex))
        {
            for (const auto& p :  pkg_match)
            {
                std::string delimiter = "=";
                std::string s = p.str();
                auto it = s.find(delimiter);
                if (it != std::string::npos)
                {
                    std::string token = (s.substr(s.find(delimiter) + 1, s.size()));
                    return Strings::trim(std::move(token));
                }
            }
        }
        return {};
    }

    Optional<NdkVersion> to_version(const std::string& version)
    {
        if (version.size() > 100) return {};
        size_t last = 0;
        size_t next = 0;
        std::vector<int> fragments(0);

        while ((next = version.find(".", last)) != std::string::npos)
        {
            fragments.push_back(std::stoi(version.substr(last, next - last)));
            last = next + 1;
        }
        fragments.push_back(std::stoi(version.substr(last)));
        if (fragments.size() == kFragmentSize)
        {
            return NdkVersion(fragments[0], fragments[1], fragments[2]);
        }
        return {};
    }

    static void compress_directory(const VcpkgPaths& paths, const fs::path& source, const fs::path& destination)
    {
        auto& fs = paths.get_filesystem();

        std::error_code ec;

        fs.remove(destination, ec);
        Checks::check_exit(
            VCPKG_LINE_INFO, !fs.exists(destination), "Could not remove file: %s", destination.u8string());
#if defined(_WIN32)
        auto&& seven_zip_exe = paths.get_tool_exe(Tools::SEVEN_ZIP);

        System::cmd_execute_and_capture_output(
            Strings::format(
                R"("%s" a "%s" "%s\*")", seven_zip_exe.u8string(), destination.u8string(), source.u8string()),
            System::get_clean_environment());
#else
        System::cmd_execute_clean(
            Strings::format(R"(cd '%s' && zip --quiet -r '%s' *)", source.u8string(), destination.u8string()));
#endif
    }

    static void maven_install(const fs::path& aar, const fs::path& pom, const Options& prefab_options)
    {
        if(prefab_options.enable_debug){
            System::print2("\n[DEBUG] Installing POM and AAR file to ~/.m2\n\n");
        }
        const char* cmd_line_format = prefab_options.enable_debug ? R"("%s" "install:install-file" "-Dfile=%s" "-DpomFile=%s")"
        : R"("%s" "-q" "install:install-file" "-Dfile=%s" "-DpomFile=%s")";

        const auto cmd_line = Strings::format(cmd_line_format,
                                              Tools::MAVEN,
                                              aar.u8string(),
                                              pom.u8string());
        const int exit_code = System::cmd_execute_clean(cmd_line);
        Checks::check_exit(VCPKG_LINE_INFO, exit_code == 0, "Error: %s installing maven file", aar.generic_u8string());
    }

    static Build::PreBuildInfo build_info_from_triplet(const VcpkgPaths& paths,
                                                const std::unique_ptr<CMakeVars::CMakeVarProvider>& provider,
                                                const Triplet& triplet)
    {
        provider->load_generic_triplet_vars(triplet);
        const Build::PreBuildInfo pre_build_info(
            paths, triplet, provider->get_generic_triplet_vars(triplet).value_or_exit(VCPKG_LINE_INFO));
        return pre_build_info;
    }

    static bool is_supported(const Build::PreBuildInfo& info)
    {
        return Strings::case_insensitive_ascii_equals(info.cmake_system_name, "android");
    }

    void do_export(const std::vector<ExportPlanAction>& export_plan,
                   const VcpkgPaths& paths,
                   const Options& prefab_options,
                   const Triplet& default_triplet)
    {
        auto provider = CMakeVars::make_triplet_cmake_var_provider(paths);

        auto build_info = build_info_from_triplet(paths, provider, default_triplet);
        Checks::check_exit(VCPKG_LINE_INFO, is_supported(build_info), "Currenty supported on android triplets");

        std::vector<VcpkgPaths::TripletFile> available_triplets = paths.get_available_triplets();

        std::unordered_map<CPUArchitecture, std::string> required_archs = {
            {CPUArchitecture::ARM, "armeabi-v7a"},
            {CPUArchitecture::ARM64, "arm64-v8a"},
            {CPUArchitecture::X86, "x86"},
            {CPUArchitecture::X64, "x86_64"}};

        std::unordered_map<CPUArchitecture, int> cpu_architecture_api_map = {{CPUArchitecture::ARM64, 21},
                                                             {CPUArchitecture::ARM, 16},
                                                             {CPUArchitecture::X64, 21},
                                                             {CPUArchitecture::X86, 16}};


        std::vector<Triplet> triplets;
        std::unordered_map<Triplet, std::string> triplet_abi_map;
        std::unordered_map<Triplet, int> triplet_api_map;

        for (auto& triplet_file : available_triplets){
            if (triplet_file.name.size() > 0){
                Triplet triplet = Triplet::from_canonical_name(std::move(triplet_file.name));
                auto triplet_build_info = build_info_from_triplet(paths, provider, triplet);
                if (is_supported(triplet_build_info)){
                    auto cpu_architecture = System::to_cpu_architecture(triplet_build_info.target_architecture).value_or_exit(VCPKG_LINE_INFO);
                    auto required_arch = required_archs.find(cpu_architecture);
                    if (required_arch != required_archs.end()){
                        triplets.push_back(triplet);
                        triplet_abi_map[triplet] = required_archs[cpu_architecture];
                        triplet_api_map[triplet] = cpu_architecture_api_map[cpu_architecture];
                        required_archs.erase(required_arch);
                    }
                }
            }
        }


        Checks::check_exit(
            VCPKG_LINE_INFO, required_archs.empty(), "Export requires the following architectures arm64-v8a, armeabi-v7a, x86_64, x86 to be present");

        Optional<std::string> android_ndk_home = System::get_environment_variable("ANDROID_NDK_HOME");

        Checks::check_exit(
            VCPKG_LINE_INFO, android_ndk_home.has_value(), "Error: ANDROID_NDK_HOME environment missing");

        Files::Filesystem& utils = paths.get_filesystem();

        const fs::path ndk_location = android_ndk_home.value_or_exit(VCPKG_LINE_INFO);

        Checks::check_exit(VCPKG_LINE_INFO,
                           utils.exists(ndk_location),
                           "Error: ANDROID_NDK_HOME Directory does not exists %s",
                           ndk_location.generic_u8string());
        const fs::path source_properties_location = ndk_location / "source.properties";

        Checks::check_exit(VCPKG_LINE_INFO,
                           utils.exists(ndk_location),
                           "Error: source.properties missing in ANDROID_NDK_HOME directory %s",
                           source_properties_location.generic_u8string());

        std::string content = utils.read_contents(source_properties_location, VCPKG_LINE_INFO);

        Optional<std::string> version_opt = find_ndk_version(content);

        Checks::check_exit(VCPKG_LINE_INFO,
                           version_opt.has_value(),
                           "Error: NDK version missing %s",
                           source_properties_location.generic_u8string());

        NdkVersion version = to_version(version_opt.value_or_exit(VCPKG_LINE_INFO)).value_or_exit(VCPKG_LINE_INFO);

        const fs::path vcpkg_root_path = paths.root;
        const fs::path raw_exported_dir_path = vcpkg_root_path / "prefab";

        utils.remove_all(raw_exported_dir_path, VCPKG_LINE_INFO);

        /*
        prefab
        └── <name>
            ├── aar
            │   ├── AndroidManifest.xml
            │   ├── META-INF
            │   │   └── LICENCE
            │   └── prefab
            │       ├── modules
            │       │   └── <module>
            │       │       ├── include
            │       │       ├── libs
            │       │       │   ├── android.arm64-v8a
            │       │       │   │   ├── abi.json
            │       │       │   │   └── lib<module>.so
            │       │       │   ├── android.armeabi-v7a
            │       │       │   │   ├── abi.json
            │       │       │   │   └── lib<module>.so
            │       │       │   ├── android.x86
            │       │       │   │   ├── abi.json
            │       │       │   │   └── lib<module>.so
            │       │       │   └── android.x86_64
            │       │       │       ├── abi.json
            │       │       │       └── lib<module>.so
            │       │       └── module.json
            │       └── prefab.json
            ├── <name>-<version>.aar
            └── pom.xml
        */

        std::unordered_map<std::string, std::string> version_map;

        std::error_code error_code;

        std::unordered_map<std::string, std::set<PackageSpec>> empty_package_dependencies;

        //

        for (const auto& action : export_plan)
        {

            const std::string name = action.spec.name();
            auto dependencies = action.dependencies(default_triplet);

            const auto action_build_info = Build::read_build_info(utils, paths.build_info_file_path(action.spec));
            const bool is_empty_package  = action_build_info.policies.is_enabled(Build::BuildPolicy::EMPTY_PACKAGE);


            if(is_empty_package){
                empty_package_dependencies[name] = std::set<PackageSpec>();
                for(auto dependency : dependencies){
                    if(empty_package_dependencies.find(dependency.name()) != empty_package_dependencies.end()){
                        auto& child_deps  = empty_package_dependencies[name];
                        auto& parent_deps = empty_package_dependencies[dependency.name()];
                        for(auto parent_dep: parent_deps){
                             child_deps.insert(parent_dep);
                        }
                    }
                    else {
                        empty_package_dependencies[name].insert(dependency);
                    }
                }
                continue;
            }

            const fs::path per_package_dir_path = raw_exported_dir_path / name;

            const auto& binary_paragraph = action.core_paragraph().value_or_exit(VCPKG_LINE_INFO);
            const std::string norm_version = binary_paragraph.version;

            version_map[name] = norm_version;

            System::print2("\nExporting package ", name, "...\n");

            fs::path package_directory = per_package_dir_path / "aar";
            fs::path prefab_directory = package_directory / "prefab";
            fs::path modules_directory = prefab_directory / "modules";

            utils.create_directories(modules_directory, error_code);

            std::string artifact_id = prefab_options.maybe_artifact_id.value_or(name);
            std::string group_id = prefab_options.maybe_group_id.value_or("com.vcpkg.ndk.support");
            std::string sdk_min_version = prefab_options.maybe_min_sdk.value_or("16");
            std::string sdk_target_version = prefab_options.maybe_target_sdk.value_or("29");

            std::string MANIFEST_TEMPLATE =
                R"(<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="@GROUP_ID@.@ARTIFACT_ID@" android:versionCode="1" android:versionName="1.0">
    <uses-sdk android:minSdkVersion="@MIN_SDK_VERSION@" android:targetSdkVersion="@SDK_TARGET_VERSION@" />
</manifest>)";
            std::string manifest = Strings::replace_all(std::move(MANIFEST_TEMPLATE), "@GROUP_ID@", group_id);
            manifest = Strings::replace_all(std::move(manifest), "@ARTIFACT_ID@", artifact_id);
            manifest = Strings::replace_all(std::move(manifest), "@MIN_SDK_VERSION@", sdk_min_version);
            manifest = Strings::replace_all(std::move(manifest), "@SDK_TARGET_VERSION@", sdk_target_version);

            fs::path manifest_path = package_directory / "AndroidManifest.xml";
            fs::path prefab_path = prefab_directory / "prefab.json";

            fs::path meta_dir = package_directory / "META-INF";

            utils.create_directories(meta_dir, error_code);

            const fs::path share_root =
                vcpkg_root_path / "packages" / Strings::format("%s_%s", name, action.spec.triplet());

            utils.copy_file(share_root / "share" / name / "copyright",
                            meta_dir / "LICENSE",
                            fs::copy_options::overwrite_existing,
                            error_code);

            PackageMetadata pm;
            pm.name = artifact_id;
            pm.schema = 1;
            pm.version = norm_version;

            std::set<PackageSpec> dependencies_minus_empty_packages;

            for(auto dependency: dependencies){
                if(empty_package_dependencies.find(dependency.name()) != empty_package_dependencies.end()){
                    for(auto& empty_package_dep: empty_package_dependencies[dependency.name()]){
                        dependencies_minus_empty_packages.insert(empty_package_dep);
                    }
                }
                else {
                    dependencies_minus_empty_packages.insert(dependency);
                }
            }

            std::vector<std::string> pom_dependencies;

            if (dependencies_minus_empty_packages.size() > 0)
            {
                pom_dependencies.push_back("\n<dependencies>");
            }

            for (const auto& it : dependencies_minus_empty_packages)
            {
                std::string maven_pom = R"(    <dependency>
        <groupId>@GROUP_ID@</groupId>
        <artifactId>@ARTIFACT_ID@</artifactId>
        <version>@VERSION@</version>
        <type>aar</type>
        <scope>runtime</scope>
    </dependency>)";
                std::string pom = Strings::replace_all(std::move(maven_pom), "@GROUP_ID@", group_id);
                pom = Strings::replace_all(std::move(pom), "@ARTIFACT_ID@", it.name());
                pom = Strings::replace_all(std::move(pom), "@VERSION@", version_map[it.name()]);
                pom_dependencies.push_back(pom);
                pm.dependencies.push_back(it.name());
            }

            if (dependencies_minus_empty_packages.size() > 0)
            {
                pom_dependencies.push_back("</dependencies>\n");
            }

            if(prefab_options.enable_debug){
                System::print2(Strings::format(
                "[DEBUG]\n\tWriting manifest\n\tTo %s\n\tWriting prefab meta data\n\tTo %s\n\n",
                                manifest_path.generic_u8string(), prefab_path.generic_u8string()));
            }

            utils.write_contents(manifest_path, manifest, VCPKG_LINE_INFO);
            utils.write_contents(prefab_path, pm.to_json(), VCPKG_LINE_INFO);

            if(prefab_options.enable_debug){
                 std::vector<std::string> triplet_names;
                for(auto triplet: triplets){
                    triplet_names.push_back(triplet.canonical_name());
                }
                System::print2(Strings::format("[DEBUG] Found %d triplets\n\t%s\n\n", triplets.size(),
                    Strings::join("\n\t", triplet_names)));
            }

            for (const auto& triplet : triplets)
            {
                const fs::path listfile = vcpkg_root_path / "installed" / "vcpkg" / "info" /
                                          (Strings::format("%s_%s_%s", name, norm_version, triplet) + ".list");
                const fs::path installed_dir = vcpkg_root_path / "packages" / Strings::format("%s_%s", name, triplet);
                Checks::check_exit(VCPKG_LINE_INFO,
                                   utils.exists(listfile),
                                   "Error: Packages not installed %s:%s %s",
                                   name,
                                   triplet,
                                   listfile.generic_u8string());

                fs::path libs = installed_dir / "lib";

                std::vector<fs::path> modules;

                std::vector<fs::path> modules_shared = find_modules(paths, libs, ".so");

                for (const auto& module : modules_shared)
                {
                    modules.push_back(module);
                }

                std::vector<fs::path> modules_static = find_modules(paths, libs, ".a");
                for (const auto& module : modules_static)
                {
                    modules.push_back(module);
                }

                // header only libs
                if (modules.empty())
                {
                    fs::path module_dir = modules_directory / name;
                    fs::path module_libs_dir = module_dir / "libs";
                    utils.create_directories(module_libs_dir, error_code);
                    fs::path installed_headers_dir = installed_dir / "include";
                    fs::path exported_headers_dir = module_dir / "include";

                    ModuleMetadata meta;
                    fs::path module_meta_path = module_dir / "module.json";
                    utils.write_contents(module_meta_path, meta.to_json(), VCPKG_LINE_INFO);


                    if (utils.exists(installed_headers_dir)) {
                        ignore_errors_t dummy;
                        if (!utils.exists(exported_headers_dir))
                            utils.create_directory(exported_headers_dir, dummy);
                        utils.copy(installed_headers_dir, exported_headers_dir, fs::copy_options::recursive);
                    }
                    break;
                }
                else
                {
                    for (const auto& module : modules)
                    {
                        std::string module_name = module.stem().generic_u8string();
                        std::string extension = module.extension().generic_u8string();

                        ABIMetadata ab;
                        ab.abi = triplet_abi_map[triplet];
                        ab.api =  triplet_api_map[triplet];

                        ab.stl = Strings::contains(extension, "a") ?"c++_static": "c++_shared";
                        ab.ndk = version.major();

                        if(prefab_options.enable_debug){
                            System::print2(Strings::format("[DEBUG] Found module %s:%s\n", module_name, ab.abi));
                        }

                        module_name = Strings::trim(std::move(module_name));

                        if (Strings::starts_with(module_name, "lib"))
                        {
                            module_name = module_name.substr(3);
                        }
                        fs::path module_dir = (modules_directory / module_name);
                        fs::path module_libs_dir =
                            module_dir / "libs" / Strings::format("android.%s", ab.abi);
                        utils.create_directories(module_libs_dir, error_code);

                        fs::path abi_path = module_libs_dir / "abi.json";

                        if(prefab_options.enable_debug){
                            System::print2(Strings::format("\tWriting abi metadata\n\tTo %s\n",
                                abi_path.generic_u8string()));
                        }
                        utils.write_contents(abi_path, ab.to_string(), VCPKG_LINE_INFO);

                        fs::path installed_module_path = libs / module.filename();
                        fs::path exported_module_path = module_libs_dir / module.filename();

                        utils.copy_file(installed_module_path,
                                        exported_module_path,
                                        fs::copy_options::overwrite_existing,
                                        error_code);
                        if(prefab_options.enable_debug){
                            System::print2(Strings::format("\tCopying libs\n\tFrom %s\n\tTo %s\n",
                                installed_module_path.generic_u8string(), exported_module_path.generic_u8string()));
                        }
                        fs::path installed_headers_dir = installed_dir / "include";
                        fs::path exported_headers_dir = module_libs_dir / "include";


                        if(prefab_options.enable_debug){
                            System::print2(Strings::format("\tCopying headers\n\tFrom %s\n\tTo %s\n",
                                installed_headers_dir.generic_u8string(), exported_headers_dir.generic_u8string()));
                        }

                        if (utils.exists(installed_headers_dir)) {
                            ignore_errors_t dummy;
                            if (!utils.exists(exported_headers_dir))
                                utils.create_directory(exported_headers_dir, dummy);
                            utils.copy(installed_headers_dir, exported_headers_dir, fs::copy_options::recursive);
                        }

                        ModuleMetadata meta;

                        fs::path module_meta_path = module_dir / "module.json";

                        if(prefab_options.enable_debug){
                            System::print2(Strings::format("\tWriting module metadata\n\tTo %s\n\n",
                                module_meta_path.generic_u8string()));
                        }

                        utils.write_contents(module_meta_path, meta.to_json(), VCPKG_LINE_INFO);
                    }
                }
            }

            fs::path exported_archive_path = per_package_dir_path / Strings::format("%s-%s.aar", name, norm_version);
            fs::path pom_path = per_package_dir_path / "pom.xml";

            if(prefab_options.enable_debug){
                System::print2(Strings::format("[DEBUG] Exporting AAR And POM\n\tAAR Path %s\n\tPOM Path %s\n",
                    exported_archive_path.generic_u8string(), pom_path.generic_u8string()));
            }

            compress_directory(paths, package_directory, exported_archive_path);

            std::string POM = R"(<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>


    <groupId>@GROUP_ID@</groupId>
    <artifactId>@ARTIFACT_ID@</artifactId>
    <version>@VERSION@</version>
    <packaging>aar</packaging>
    <description>The Vcpkg AAR for @ARTIFACT_ID@</description>
    <url>https://github.com/microsoft/vcpkg.git</url>
    @DEPENDENCIES@
</project>)";

            std::string pom = Strings::replace_all(std::move(POM), "@GROUP_ID@", group_id);
            pom = Strings::replace_all(std::move(pom), "@ARTIFACT_ID@", artifact_id);
            pom = Strings::replace_all(std::move(pom), "@DEPENDENCIES@", Strings::join("\n", pom_dependencies));
            pom = Strings::replace_all(std::move(pom), "@VERSION@", norm_version);

            utils.write_contents(pom_path, pom, VCPKG_LINE_INFO);

            if (prefab_options.enable_maven)
            {

                maven_install(exported_archive_path, pom_path, prefab_options);
                if(prefab_options.enable_debug){
                    System::print2(
                    Strings::format("\n\n[DEBUG] Configuration properties in Android Studio\nIn app/build.gradle\n\n\t%s:%s:%s\n\n",
                     group_id, artifact_id, norm_version));

                System::print2(R"(And cmake flags

    externalNativeBuild {
                cmake {
                    arguments '-DANDROID_STL=c++_shared'
                    cppFlags "-std=c++17"
                }
            }

)");

                System::print2(R"(In gradle.properties

    android.enablePrefab=true
    android.enableParallelJsonGen=false
    android.prefabVersion=${prefab.version}

)");}
            }
            System::print2(System::Color::success,
                           Strings::format("Successfuly exported %s. Checkout %s  \n",
                                           name,
                                           raw_exported_dir_path.generic_u8string()));
        }
    }
}
