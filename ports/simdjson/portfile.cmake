# https://github.com/Microsoft/vcpkg/issues/5418#issuecomment-470519894
vcpkg_fail_port_install(ON_ARCH "arm" "arm64" "x86")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lemire/simdjson
    REF 4da06830f1389c8cd33171f5ab3558e79f0ece04
    SHA512 ffb11ee91f97d975fba2946653c9c847565933380f94e334d15e627f77a7a750702c539ca55d17e077b2ed0a79006f56a3b9a202d888bb7e2e3f0484237cb537
    HEAD_REF master
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/no_benchmark.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SIMDJSON_BUILD_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSIMDJSON_BUILD_STATIC=${SIMDJSON_BUILD_STATIC}
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
