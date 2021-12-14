#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/wil
    REF 5a21cac10640f54b7ef886031f4d9ed427bef4c5
    SHA512 b1a6703dd75eee66f81c54bb5c01bc9acc7354c113fd556afb2dd95361db7e9f94c9e958d9a0b897359084c9c08cb725bbe214fdaccf2e662c1ca4aa73c3345a
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
# Remove this line in the next update
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/WIL-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/wilConfig.cmake")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)