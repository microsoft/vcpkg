vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephane/libmodbus
    REF "v${VERSION}"
    SHA512 6a01da1f8b486e356ff44874f1479d9d121463958a5ed06e60d910328ccc9b2d431b4a1fd72861c5c645c97b5887a076b763ad6a9ae6b18402dd043ec525b1e2
    HEAD_REF master
    PATCHES fix-static-linkage.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" "${CMAKE_CURRENT_LIST_DIR}/config.h.cmake"
     DESTINATION "${SOURCE_PATH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/modbus.h" "elif defined(LIBBUILD)" "elif 1")
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LESSER")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
