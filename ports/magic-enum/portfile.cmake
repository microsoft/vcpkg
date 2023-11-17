vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/magic_enum
    REF "v${VERSION}"
    SHA512 1c850a87fa8f449b98d748f3e74a82463d9ca5e7ddcd4c318465230d26032f75d5e103b9a27782e1e7d808156241686c22382086b9d553f9d37b32c83115552d
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
