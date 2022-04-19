vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bfgroup/Lyra
    REF 1.6
    SHA512 e357fd0e925b67a51ad7232035ac66842676837baebf7a69eb416807b11400c283d098a22bf3ae27ce904700c5b849953ede1873d6535a8b34c4704ebcb09748
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME lyra
    CONFIG_PATH share/lyra/cmake
)

# Library is header-only, so no debug content.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
