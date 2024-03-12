vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pocketpy/pocketpy
    REF "v${VERSION}"
    SHA512 994736b57250d415fbae7c7fcb82c7bed6423fb9eb97ab7fd7d1c3ad584dfa32f85dda31fa1dc49842b900d1bdf73f825a220587342cf8d0b0f85cc06c27a15a
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPK_BUILD_SHARED_LIB=${BUILD_SHARED}
        -DPK_BUILD_STATIC_LIB=${BUILD_STATIC}
        -DPK_ENABLE_OS=OFF
        -DPK_USE_CJSON=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
