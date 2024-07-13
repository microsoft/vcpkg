vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/magic_enum
    REF "v${VERSION}"
    SHA512 6154c816446e115f3b164df79ab8d8088eb76b632ee3fdc82ea17cc7ae8d04652c83e5cc587c2c4b334889904b101ba08a04c5837103af260768e93df17cc263
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMAGIC_ENUM_OPT_BUILD_EXAMPLES=OFF
        -DMAGIC_ENUM_OPT_BUILD_TESTS=OFF
        -DMAGIC_ENUM_OPT_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/magic_enum PACKAGE_NAME magic_enum)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
