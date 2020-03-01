#pragma once

#include <vcpkg/dependencies.h>
#include <vcpkg/vcpkgpaths.h>

#include <vector>

namespace vcpkg::Export::Prefab
{
    constexpr int kFragmentSize = 3;
    struct Options
    {
        Optional<std::string> maybe_group_id;
        Optional<std::string> maybe_artifact_id;
        Optional<std::string> maybe_version;
        Optional<std::string> maybe_min_sdk;
        Optional<std::string> maybe_target_sdk;
        Optional<std::string> maybe_ndk;
    };
    struct NdkVersion
    {
        NdkVersion(int _major, int _minor, int _patch) : m_major{_major},
                                                     m_minor{_minor},
                                                     m_patch{_patch}{
        }
        int major()  { return this->m_major; }
        int minor()  { return this->m_minor; }
        int patch()  { return this->m_patch; }
        std::string to_string();
        void to_string(std::string& out);

        private:
        int m_major;
        int m_minor;
        int m_patch;
    };

    struct ABIMetadata
    {
        std::string abi;
        int api;
        int ndk;
        std::string stl;
        std::string to_string();
    };

    struct PlatformModuleMetadata
    {
        std::vector<std::string> export_libraries;
        std::string library_name;
        std::string to_json();
    };

    struct ModuleMetadata
    {
        std::vector<std::string> export_libraries;
        std::string library_name;
        PlatformModuleMetadata android;
        std::string to_json();
    };

    struct PackageMetadata
    {
        std::string name;
        int schema;
        std::vector<std::string> dependencies;
        std::string version;
        std::string to_json();
    };



    void do_export(const std::vector<Dependencies::ExportPlanAction>& export_plan,
                   const VcpkgPaths& paths,
                   const Options& prefab_options);
    Optional<std::string> find_ndk_version(const std::string &content);
    Optional<NdkVersion> to_version(const std::string &version);
}
