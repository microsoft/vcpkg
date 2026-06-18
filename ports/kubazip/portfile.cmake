vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kuba--/zip
    REF "v${VERSION}"
    SHA512 fb5841f11fa5a7f6f1457952d57b61349ad2bcdda0b2b7b0045655a03bd6c743ad3b68cc510147b3b9bbd1962f753d46f66d251df82bf6dc65c117dd23b8e743
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
