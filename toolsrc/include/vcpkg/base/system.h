#pragma once

#include <vcpkg/base/files.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/stringview.h>
#include <vcpkg/base/zstringview.h>

namespace vcpkg::System
{
    Optional<std::string> get_environment_variable(ZStringView varname) noexcept;

    const ExpectedS<fs::path>& get_home_dir() noexcept;

    const ExpectedS<fs::path>& get_platform_cache_home() noexcept;

#ifdef _WIN32
    const ExpectedS<fs::path>& get_appdata_local() noexcept;
#endif

    Optional<std::string> get_registry_string(void* base_hkey, StringView subkey, StringView valuename);

    enum class CPUArchitecture
    {
        X86,
        X64,
        ARM,
        ARM64,
        S390X,
    };

    Optional<CPUArchitecture> to_cpu_architecture(StringView arch);

    ZStringView to_zstring_view(CPUArchitecture arch) noexcept;

    CPUArchitecture get_host_processor();

    std::vector<CPUArchitecture> get_supported_host_architectures();

    const Optional<fs::path>& get_program_files_32_bit();

    const Optional<fs::path>& get_program_files_platform_bitness();

    int get_num_logical_cores();

    Optional<CPUArchitecture> guess_visual_studio_prompt_target_architecture();
}
