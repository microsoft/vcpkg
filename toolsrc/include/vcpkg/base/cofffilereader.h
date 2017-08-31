#pragma once

#include <vcpkg/base/files.h>
#include <vcpkg/base/machinetype.h>

#include <vector>

namespace vcpkg::CoffFileReader
{
    struct PESubsystem
    {
        uint16_t subsystem=0;
        uint16_t subsystem_major_version=0;
        uint16_t subsystem_minor_version=0;

        std::string to_string() const
        {
            return std::to_string(subsystem_major_version) + "." + std::to_string(subsystem_minor_version);
        }

        bool compare_version(PESubsystem& obj) const
        {
            return (subsystem_major_version == obj.subsystem_major_version) && (subsystem_minor_version == obj.subsystem_minor_version);
        }
    };

    struct DllInfo
    {
        MachineType machine_type;
        PESubsystem subsystem;
    };

    struct LibInfo
    {
        std::vector<MachineType> machine_types;
    };

    DllInfo read_dll(const fs::path& path);

    LibInfo read_lib(const fs::path& path);
}
