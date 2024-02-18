vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pocketpy/pocketpy
    REF "v${VERSION}"
    SHA512 fe78e896b656fedbd60da02bf8497c7fc4254109160c72198dc066f2530c69fa0dcd069d6d3241a95709d803a5dfd6f89acf2b6c40a40b7b8f2b262de29d01a3
    HEAD_REF master
    PATCHES
        add-cmake-install.patch
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
