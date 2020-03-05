#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/commands.h>
#include <vcpkg/export.h>
#include <vcpkg/export.prefab.h>
#include <vcpkg/install.h>

namespace vcpkg::Export::Prefab
{
    using Dependencies::ExportPlanAction;
    using Dependencies::ExportPlanType;
    using Install::InstallDir;

    static std::string POM = R"(<?xml version="1.0" encoding="UTF-8"?>
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

    <dependencies>
     @DEPENDENCIES@
    </dependencies>
</project>)";

    std::vector<fs::path> find_modules(const fs::path& root, const std::string& ext)
    {
        std::vector<fs::path> paths;
        if (!fs::stdfs::exists(root) || !fs::stdfs::is_directory(root)) return paths;

        fs::stdfs::recursive_directory_iterator it(root);
        fs::stdfs::recursive_directory_iterator endit;

        while (it != endit)
        {
            if (fs::stdfs::is_regular_file(*it) && it->path().extension() == ext)
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

    std::string jsonify(const std::vector<std::string>& dependencies)
    {
        std::vector<std::string> deps;
        for (auto it = dependencies.begin(); it != dependencies.end(); ++it)
        {
            deps.push_back("\"" + *it + "\"");
        }
        return Strings::join(",", deps);
    }

    std::string null_if_empty(const std::string& str)
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

    std::string null_if_empty_array(const std::string& str)
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
            for (auto p = pkg_match.begin(); p != pkg_match.end(); ++p)
            {
                std::string delimiter = "=";
                std::string s = p->str();
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

    void maven_install(const fs::path& aar, const fs::path& pom)
    {
        const auto cmd_line = Strings::format(
            R"("%s" "install:install-file" "-Dfile=%s" "-DpomFile=%s")", Tools::MAVEN, aar.u8string(), pom.u8string());
        const int exit_code = System::cmd_execute_clean(cmd_line);
        Checks::check_exit(VCPKG_LINE_INFO, exit_code == 0, "Error: %s installing maven file", aar.generic_string());
    }

    void do_export(const std::vector<ExportPlanAction>& export_plan,
                   const VcpkgPaths& paths,
                   const Options& prefab_options)
    {
        std::unordered_map<Triplet, std::string> triplet_abi_map = {{Triplet::ARM64_ANDROID, "arm64-v8a"},
                                                                    {Triplet::ARM_ANDROID, "armeabi-v7a"},
                                                                    {Triplet::X64_ANDROID, "x86_64"},
                                                                    {Triplet::X86_ANDROID, "x86"}

        };

        std::unordered_map<Triplet, int> triplet_api_map = {{{Triplet::ARM64_ANDROID, 21},
                                                             {Triplet::ARM_ANDROID, 16},
                                                             {Triplet::X64_ANDROID, 21},
                                                             {Triplet::X86_ANDROID, 16}}};
        std::vector<Triplet> required_triplets = {
            Triplet::ARM64_ANDROID, Triplet::ARM_ANDROID, Triplet::X64_ANDROID, Triplet::X86_ANDROID};
        Optional<std::string> android_ndk_home = System::get_environment_variable("ANDROID_NDK_HOME");

        Checks::check_exit(
            VCPKG_LINE_INFO, android_ndk_home.has_value(), "Error: ANDROID_NDK_HOME environment missing");

        Files::Filesystem& utils = paths.get_filesystem();

        const fs::path ndk_location = android_ndk_home.value_or_exit(VCPKG_LINE_INFO);

        Checks::check_exit(VCPKG_LINE_INFO,
                           fs::stdfs::exists(ndk_location),
                           "Error: ANDROID_NDK_HOME Directory does not exists %s",
                           ndk_location.c_str());
        const fs::path source_properties_location = ndk_location / "source.properties";

        Checks::check_exit(VCPKG_LINE_INFO,
                           fs::stdfs::exists(ndk_location),
                           "Error: source.properties missing in ANDROID_NDK_HOME directory %s",
                           source_properties_location);

        std::string content = utils.read_contents(source_properties_location, VCPKG_LINE_INFO);

        Optional<std::string> version_opt = find_ndk_version(content);

        Checks::check_exit(
            VCPKG_LINE_INFO, version_opt.has_value(), "Error: NDK version missing %s", source_properties_location);

        NdkVersion version = to_version(version_opt.value_or_exit(VCPKG_LINE_INFO)).value_or_exit(VCPKG_LINE_INFO);

        const fs::path vcpkg_root_path = paths.root;
        const fs::path raw_exported_dir_path = vcpkg_root_path / "prefab";

        fs::stdfs::remove_all(raw_exported_dir_path);

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

        for (const ExportPlanAction& action : export_plan)
        {
            const std::string name = action.spec.name();
            const fs::path per_package_dir_path = raw_exported_dir_path / name;

            const BinaryParagraph& binary_paragraph = action.core_paragraph().value_or_exit(VCPKG_LINE_INFO);
            const std::string norm_version = binary_paragraph.version;

            System::print2("Exporting package ", name, "...\n");

            fs::path package_directory = per_package_dir_path / "aar";
            fs::path prefab_directory = package_directory / "prefab";
            fs::path modules_directory = prefab_directory / "modules";

            fs::stdfs::create_directories(modules_directory);

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

            fs::stdfs::create_directories(meta_dir);

            const fs::path share_root =
                vcpkg_root_path / "packages" / Strings::format("%s_%s", name, action.spec.triplet());

            fs::stdfs::copy(share_root / "share" / name / "copyright", meta_dir / "LICENCE");

            PackageMetadata pm;
            pm.name = artifact_id;
            pm.schema = 1;
            pm.version = norm_version;

            auto dependencies = action.dependencies(Triplet::ARM64_ANDROID);
            for (auto it = dependencies.begin(); it != dependencies.end(); ++it)
            {
                pm.dependencies.push_back(it->name());
            }

            utils.write_contents(manifest_path, manifest, VCPKG_LINE_INFO);
            utils.write_contents(prefab_path, pm.to_json(), VCPKG_LINE_INFO);

            for (auto triplet : required_triplets)
            {
                const fs::path listfile = vcpkg_root_path / "installed" / "vcpkg" / "info" /
                                          (Strings::format("%s_%s_%s", name, norm_version, triplet) + ".list");
                const fs::path installed_dir = vcpkg_root_path / "packages" / Strings::format("%s_%s", name, triplet);
                Checks::check_exit(VCPKG_LINE_INFO,
                                   fs::stdfs::exists(listfile),
                                   "Error: Packages not installed %s:%s %s",
                                   name,
                                   triplet,
                                   listfile);

                fs::path libs = installed_dir / "lib";

                std::vector<fs::path> modules = find_modules(libs, ".so");

                for (auto module : modules)
                {
                    std::string module_name = module.stem().generic_string();
                    module_name = Strings::trim(std::move(module_name));

                    if (Strings::starts_with(module_name, "lib"))
                    {
                        module_name = module_name.substr(3);
                    }
                    fs::path module_dir = (modules_directory / module_name);
                    fs::path module_libs_dir =
                        module_dir / "libs" / Strings::format("android.%s", triplet_abi_map[triplet]);
                    fs::stdfs::create_directories(module_libs_dir);
                    ABIMetadata ab;
                    ab.abi = triplet_abi_map[triplet];
                    ab.api = triplet_api_map[triplet];
                    ab.stl = "c++_shared";
                    ab.ndk = version.major();

                    fs::path abi_path = module_libs_dir / "abi.json";
                    utils.write_contents(abi_path, ab.to_string(), VCPKG_LINE_INFO);

                    fs::path installed_module_path = libs / module.filename();
                    fs::path exported_module_path = module_libs_dir / module.filename();

                    fs::stdfs::copy(installed_module_path, exported_module_path);

                    fs::path installed_headers_dir = installed_dir / "include";
                    fs::path exported_headers_dir = module_libs_dir / "include";

                    fs::stdfs::copy(installed_headers_dir, exported_headers_dir, fs::stdfs::copy_options::recursive);

                    ModuleMetadata meta;

                    fs::path module_meta_path = module_dir / "module.json";

                    utils.write_contents(module_meta_path, meta.to_json(), VCPKG_LINE_INFO);
                }
            }

            fs::path exported_archive_path =
                raw_exported_dir_path / name / Strings::format("%s-%s.aar", name, norm_version);
            fs::path pom_path = raw_exported_dir_path / name / "pom.xml";

            compress_directory(paths, package_directory, exported_archive_path);

            std::string pom = Strings::replace_all(std::move(POM), "@GROUP_ID@", group_id);
            pom = Strings::replace_all(std::move(pom), "@ARTIFACT_ID@", artifact_id);
            pom = Strings::replace_all(std::move(pom), "@DEPENDENCIES@", "");
            pom = Strings::replace_all(std::move(pom), "@VERSION@", norm_version);

            utils.write_contents(pom_path, pom, VCPKG_LINE_INFO);

            if (prefab_options.enable_maven)
            {
                maven_install(exported_archive_path, pom_path);
            }
            System::print2(System::Color::success, Strings::format("Successfuly installed %s. Checkout %s  \n", name, raw_exported_dir_path.generic_string()));
        }
    }
}
