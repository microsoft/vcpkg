vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jhasse/poly2tri
    REF 0171f030bd3d5c6747c29d93403546eed668a1b6
    SHA512 b55d543ae7f9b447d3e0e39b66cf1ce55a48ed7949819db01d8adc0972182519c4b6b533e704a282da45a4d64f510fd33cd81ccb52307dc0e63622e83bcf0192
    HEAD_REF master
    PATCHES
        cmake.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME poly2tri)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
