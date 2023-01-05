vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tencent/ncnn
    REF 20220729
    SHA512 0df877ee42edc32faa6891c8b234fc21064b18c1dc8c612b43757daf5f912530f3d015c783e6e199c2884616a88137d10f9c899528000f25e9d0881f028a9586
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
