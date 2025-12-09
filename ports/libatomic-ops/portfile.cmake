vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bdwgc/libatomic_ops
    REF "v${VERSION}"
    SHA512 3980e52faaef12fe5794389a88c985124b408e7c2051aae5966939ee1577cd0b7a9e807a373791086f38fb82a7dc2bd062ebbe8efc1124383060f78625fb99cc
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
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
