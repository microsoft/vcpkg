# https://github.com/Microsoft/vcpkg/issues/5418#issuecomment-470519894
vcpkg_fail_port_install(ON_ARCH "x86")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lemire/simdjson
    REF c75009524150e105068a10c57f3ad4f1e241ada0
    SHA512 03187bef8a0395719030c77b4435bb234e9659b05640caf42aeafb944f61b85d7fe7d59998ea4b5e83afa212bf263557ea5946ddf045c8698335bceedbbf0b1b
    HEAD_REF master
    PATCHES
        no_benchmark.patch # `_pclose` is not available on UWP
        fix_uwp_build.patch # On x64-uwp, size_t -> unsigned long long, DWORD -> unsigned long
        install_string_view_hpp.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SIMDJSON_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_TARGET_ARCHITECTURE}" "arm64" SIMDJSON_IMPLEMENTATION_ARM64)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSIMDJSON_BUILD_STATIC=${SIMDJSON_BUILD_STATIC}
        -DSIMDJSON_IMPLEMENTATION_ARM64=${SIMDJSON_IMPLEMENTATION_ARM64}
    OPTIONS_DEBUG
        -DSIMDJSON_SANITIZE=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
