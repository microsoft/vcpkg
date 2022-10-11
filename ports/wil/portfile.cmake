#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/wil
    REF f9284c19c9873664978b873b8858d7dfacc6af1e
    SHA512 df81e7f12f15f8e382f537f783c33c9833bb83c4d86d571bd47503e7400698686f51a8a50efd2224c95a5409ab8ef719186d806afbfc4ea2af8d4fd7f8dce024
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWIL_BUILD_TESTS=OFF
        -DWIL_BUILD_PACKAGING=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/WIL)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)