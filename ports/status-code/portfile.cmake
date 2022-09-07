vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/status-code
    REF 60ec9e46916e5170051293e7925729ba88951934
    SHA512 f7a9448419f8e9228cd29c3b2e9268712de985675acea3b51f742ce88e524e7f51ccea7e08c89bf4e6d38eb1131416af052192531c168eed1f45e7eeda20fed6
    HEAD_REF master
    PATCHES
        no-target-sources.patch # see https://github.com/ned14/status-code/issues/43
)

# Because status-code's deployed files are header-only, the debug build is not necessary
set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPROJECT_IS_DEPENDENCY=On
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/status-code)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(RENAME "${CURRENT_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/include2")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include2" "${CURRENT_PACKAGES_DIR}/include/status-code")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/Licence.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
