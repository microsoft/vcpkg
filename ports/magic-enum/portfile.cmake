# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/magic_enum
    REF v0.8.2
    SHA512 849c426484156faf91dde3f32f6c755c7698879b16dd83e13fb86b299b53ec9bbe4d55267581386302c8acb93d80ec044cc248371fdc8608cdd8f4ab12099f0a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMAGIC_ENUM_OPT_ENABLE_NONASCII=OFF
        -DMAGIC_ENUM_OPT_BUILD_EXAMPLES=OFF
        -DMAGIC_ENUM_OPT_BUILD_TESTS=OFF
        -DMAGIC_ENUM_OPT_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/magic_enum PACKAGE_NAME magic_enum)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
