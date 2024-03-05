vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gul-cpp/gul14
    REF v2.10.0
    SHA512 497e95a8bbd3a8060f3775de561afe755aac0054bd4279da6aea79b1bd35d111c41f92622a0a7e8ba99f6c5aa2dd3a2b2a10c2534482c36cf8c80d0b8ce3fe8a
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_meson()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

# Install copyright file
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
