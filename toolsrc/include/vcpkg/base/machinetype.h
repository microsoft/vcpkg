#pragma once

#include <cstdint>

namespace vcpkg
{
    enum class MachineType : uint16_t
    {
        UNKNOWN = 0x0,     // The contents of this field are assumed to be applicable to any machine type
        AM33 = 0x1d3,      // Matsushita AM33
        AMD64 = 0x8664,    // x64
        ARM = 0x1c0,       // ARM little endian
        ARM64 = 0xaa64,    // ARM64 little endian
        ARMNT = 0x1c4,     // ARM Thumb-2 little endian
        EBC = 0xebc,       // EFI byte code
        I386 = 0x14c,      // Intel 386 or later processors and compatible processors
        IA64 = 0x200,      // Intel Itanium processor family
        M32R = 0x9041,     // Mitsubishi M32R little endian
        MIPS16 = 0x266,    // MIPS16
        MIPSFPU = 0x366,   // MIPS with FPU
        MIPSFPU16 = 0x466, // MIPS16 with FPU
        POWERPC = 0x1f0,   // Power PC little endian
        POWERPCFP = 0x1f1, // Power PC with floating point support
        R4000 = 0x166,     // MIPS little endian
        RISCV32 = 0x5032,  // RISC-V 32-bit address space
        RISCV64 = 0x5064,  // RISC-V 64-bit address space
        RISCV128 = 0x5128, // RISC-V 128-bit address space
        SH3 = 0x1a2,       // Hitachi SH3
        SH3DSP = 0x1a3,    // Hitachi SH3 DSP
        SH4 = 0x1a6,       // Hitachi SH4
        SH5 = 0x1a8,       // Hitachi SH5
        THUMB = 0x1c2,     // Thumb
        WCEMIPSV2 = 0x169, // MIPS little-endian WCE v2
    };

    MachineType to_machine_type(const uint16_t value);
}
