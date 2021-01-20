#include <vcpkg/base/checks.h>
#include <vcpkg/base/machinetype.h>

namespace vcpkg
{
    MachineType to_machine_type(const uint16_t value)
    {
        const MachineType t = static_cast<MachineType>(value);
        switch (t)
        {
            case MachineType::UNKNOWN:
            case MachineType::AM33:
            case MachineType::AMD64:
            case MachineType::ARM:
            case MachineType::ARM64:
            case MachineType::ARMNT:
            case MachineType::EBC:
            case MachineType::I386:
            case MachineType::IA64:
            case MachineType::M32R:
            case MachineType::MIPS16:
            case MachineType::MIPSFPU:
            case MachineType::MIPSFPU16:
            case MachineType::POWERPC:
            case MachineType::POWERPCFP:
            case MachineType::R4000:
            case MachineType::RISCV32:
            case MachineType::RISCV64:
            case MachineType::RISCV128:
            case MachineType::SH3:
            case MachineType::SH3DSP:
            case MachineType::SH4:
            case MachineType::SH5:
            case MachineType::THUMB:
            case MachineType::WCEMIPSV2: return t;
            default: Checks::exit_maybe_upgrade(VCPKG_LINE_INFO, "Unknown machine type code 0x%hx", value);
        }
    }
}
