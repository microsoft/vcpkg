vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kuba--/zip
    REF "v${VERSION}"
    SHA512 e35df05d1db4542223f251b052094a8926f1e84a9051db3ff3f60cd0c3af912e0e3053852df8f24eb37b25c0be90afe058c613e9139ccfad0c3ad4d3950c2e70
    HEAD_REF master
    PATCHES
        fix-name-conflict.diff
        disable-werror.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_TESTING=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/zip" PACKAGE_NAME "zip-kuba--")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/kubazip/zip/zip.h" "#ifndef ZIP_SHARED" "#if 0")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# legacy polyfill
file(INSTALL "${CURRENT_PORT_DIR}/kubazipConfig.cmake" "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
