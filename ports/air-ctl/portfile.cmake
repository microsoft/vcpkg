vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  inie0722/CTL
    REF fc9129720646b7e4e2bda9565aff8b2f447fbc2c #v1.1.2
    SHA512 23cd6d17997ab6bba8fba117fc0bd5a50fd4a37a2f2ce11164596b19fe3284536dbe19108ca27576842fdf808c40961c471c898844fe74580d3d6d1877833920
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "-DCTL_CACHE_LINE_SIZE=0"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
