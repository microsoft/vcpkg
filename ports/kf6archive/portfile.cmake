vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/karchive
    REF "v${VERSION}"
    SHA512 f87fd53ba029b05d3c233ea8d8a9dbb7b2aba2aec55a38b26cfd0f6e1c49d8c1297c06d634175ccc5bbbce00261a3387a2da3c705011e9cbae538eae2723fef3
    HEAD_REF master
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTING=OFF
        -DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF6Archive)
vcpkg_copy_pdbs()

# Static builds should not have libraries in the bin directory
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/data")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/data")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
