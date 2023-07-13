vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tencent/ncnn
    REF 20221128
    SHA512 589e52b63eabfac1f8e47acc34bef6a87ce365851a5c4d551665c321938a2d8e622ab211babac38771695b9f4443516577ba1634409a55c2436498a7d28d8218
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNCNN_BUILD_TOOLS=OFF
        -DNCNN_BUILD_EXAMPLES=OFF
        -DNCNN_BUILD_BENCHMARK=OFF
        -DNCNN_SHARED_LIB=${BUILD_SHARED}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ncnn)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
