set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO corrosion-rs/corrosion
    REF "v${VERSION}"
    SHA512 274baca57f7d599b304b75a73067fae9eb488eec10925fade7e195d494a192760b116a3bdf289e0cb7c291b29684909d5fd1c9404c6d37203c883cd511849bbb
    HEAD_REF master
    PATCHES
        "vcpkg-install.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCORROSION_VCPKG_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Corrosion)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
