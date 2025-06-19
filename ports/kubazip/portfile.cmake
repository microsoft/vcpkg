vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kuba--/zip
    REF "v${VERSION}"
    SHA512 dd516f2e6765e49c00063bd72b49d97bc6f1254921045269b534a801e41e0728171cbf09a73713b236f40c4cf30b5473e74579b82962004b79166b38ad6a3e0d
    HEAD_REF master
    PATCHES
        fix-name-conflict.diff
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
