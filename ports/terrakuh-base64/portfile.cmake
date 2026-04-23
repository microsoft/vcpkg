vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO terrakuh/base64
    REF 412f1645f7aeeb55b78377eefc65e6d7b36ec25b
    SHA512 d31b3a450583c2deaa8da1e8a18206075d07d5a58302e1e7720bbe6e61de082e7a7f2cf1f15d1c61ce3962d6089410c784dbc1f81993c940d3cadbeaa91c1e4b
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME base64 CONFIG_PATH lib/cmake/base64)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
