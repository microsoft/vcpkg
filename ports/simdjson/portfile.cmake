# https://github.com/Microsoft/vcpkg/issues/5418#issuecomment-470519894
vcpkg_fail_port_install(ON_ARCH "x86")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lemire/simdjson
    REF 8927a0561f7ef7e5b1830cb2b19f8418b27cbbfd
    SHA512 dcca09fa4dedcb003e51fa8cd8e06a38965555588a68724602d80c8a82db222a7a41db94a62920f779b7562c6902b4496987ffb5c827e9dbf626edd1a0f0ed55
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
        -DSIMDJSON_SANITIZE=OFF # issue 10145
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
