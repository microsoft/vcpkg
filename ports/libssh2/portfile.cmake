include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libssh2/libssh2
    REF 42d37aa63129a1b2644bf6495198923534322d64
    SHA512 e86c0787e2aa7be5e9f19356e543493e53c7d1b51b585c46facfb05f769e6491209f820b207bf594348f4760c492c32dda3fcc94fc0af93cb09c736492a8e231
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
