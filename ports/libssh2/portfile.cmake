include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libssh2/libssh2
    REF libssh2-1.8.0
    SHA512 c157db0628126d6348ed52a698fbdd7e20b54b6115123bd7d238f02fda5c68ca7a1585aed8a2376df0840f4a3823743133996192001ae54864ab53c954b938e7
    HEAD_REF master
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-Fix-UWP.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_ZLIB_COMPRESSION=ON
    OPTIONS_DEBUG
        -DENABLE_DEBUG_LOGGING=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libssh2)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libssh2 RENAME copyright)

vcpkg_copy_pdbs()
