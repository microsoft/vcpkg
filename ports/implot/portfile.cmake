vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO epezent/implot
    REF v0.7
    SHA512 b4b1c8ab8d031c884626cf2b31d30baa786b5a1942aabf0856cdb8f2fa091c8117d165c4789a5f9b58ae7a01e89e43e7145a308cfe64af6e28da776d1707c125
    HEAD_REF master
    PATCHES mac_os_build_fix.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DIMPLOT_SKIP_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)