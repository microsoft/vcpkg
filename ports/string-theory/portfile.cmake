vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zrax/string_theory
    REF 3.6
    SHA512 2bbd8e6c5c2501cc9616ee6a77b60a7cac5e7c9fa58d6616f6ba39cfdee33dc1b072c5d1b34bd2f88726fb4d65d32032595be7a67854a2e894eb3d81d4a8eea9
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME string_theory CONFIG_PATH lib/cmake/string_theory)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
