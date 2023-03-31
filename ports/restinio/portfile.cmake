vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF 09f5a340bbd99e65c5d2a547c401f67a97ac1d19 # v.0.6.18
    SHA512 be48c153aacf95bf246f69b7ffe52d33ae047a0e33c6d983acd42b6b548a28bcd3f3c412b4a26f12a5c53d1e0ee9b26e162583c7f46d01225f203e992354eb5a
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/vcpkg"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/restinio)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")
# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
