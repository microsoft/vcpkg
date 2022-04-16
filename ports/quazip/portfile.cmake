vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stachenov/quazip
    REF v1.2
    SHA512 3f4b1a4194ca286163b1c17880ea471a341dcc05d758ee8f3d1e540d0f6aed7ac18200450187034c46b4fab1da39111dca534d75859701259406a6dd50205386
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/QuaZip-Qt5-1.2)
vcpkg_copy_pdbs()
if(VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
else()
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/" RENAME copyright)