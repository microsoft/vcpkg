vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fraillt/bitsery
    REF "v${VERSION}"
    SHA512 26e525d799d1777e182753c6c970765be8695a557e0fef35224ab8f4629a094c04fd8d7e456da369938d74acb0ca84084f394f212ae1343fa62a27256dba971f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
