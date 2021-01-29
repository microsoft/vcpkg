#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/wil
    REF 3c00e7f1d8cf9930bbb8e5be3ef0df65c84e8928
    SHA512 c9c3b4a41f7523a6da6378def4a6b868e9f66438998d04ae8489b9784db91664af7af3ab6ef73c104b9ac100c0dc5ae6a13e9cb9f679ba428a4abc07b32a7dce
    HEAD_REF master
    PATCHES fix-install-headers.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWIL_BUILD_TESTS=OFF
        -DWIL_BUILD_PACKAGING=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/WIL)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/wil" RENAME copyright)