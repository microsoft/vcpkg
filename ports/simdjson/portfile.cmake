# https://github.com/Microsoft/vcpkg/issues/5418#issuecomment-470519894
vcpkg_fail_port_install(ON_ARCH "x86")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lemire/simdjson
    REF 12150baa5e4d35a9cb4b5a6d6faf4e1a0bae0ddd
    SHA512 d3b9b54aa2b24fdddfcacf7621c7811c084ae0c29cffe0a80af52494562c822121b4da0f0fee502c75aecc9100333fce4a55d1a67debe74630b702a919d6bb15
    HEAD_REF master
    PATCHES
        no_benchmark.patch # `_pclose` is not available on UWP
        fix_uwp_build.patch # On x64-uwp, size_t -> unsigned long long, DWORD -> unsigned long
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SIMDJSON_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_TARGET_ARCHITECTURE}" "arm64" SIMDJSON_IMPLEMENTATION_ARM64)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSIMDJSON_BUILD_STATIC=${SIMDJSON_BUILD_STATIC}
        -DSIMDJSON_IMPLEMENTATION_ARM64=${SIMDJSON_IMPLEMENTATION_ARM64}
        -DSIMDJSON_GOOGLE_BENCHMARKS=OFF
        -DSIMDJSON_COMPETITION=OFF
        -DSIMDJSON_SANITIZE=OFF # issue 10145, pr 11495
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
