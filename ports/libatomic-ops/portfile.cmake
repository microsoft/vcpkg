vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ivmai/libatomic_ops
    REF 7a8de3bd9c6c61c68a866b849e7b1d17d76d2d36 # v7.7.0-20211109
    SHA512 05555792a199526d8e164833f590cc57c5ee34672d81952787a09dd7008e947e4e8b6ad63fb6b8ee315294b98fdf743639622b3d9156d8a8f8363b431e875c45
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Denable_docs=OFF
    OPTIONS_DEBUG
        -Dinstall_headers=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME atomic_ops CONFIG_PATH lib/cmake/atomic_ops)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
