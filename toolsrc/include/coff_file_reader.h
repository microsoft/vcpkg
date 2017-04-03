#pragma once
#include <vector>
#include "MachineType.h"
#include "filesystem_fs.h"

namespace vcpkg::COFFFileReader
{
    struct DllInfo
    {
        MachineType machine_type;
    };

    struct LibInfo
    {
        std::vector<MachineType> machine_types;
    };

    DllInfo read_dll(const fs::path& path);

    LibInfo read_lib(const fs::path& path);
}
