# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mandreyel/mio
    REF 3f86a95c0784d73ce6815237ec33ed25f233b643
    SHA512 18bbc41d5c3b29ecafe19cef29687380d8f4f27279af08edb0d5e65ee1d71162f3cf75d8efaa324cd11301f3f49fadaec3e4c1514607d5065ddd7a65bf32ee2a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dmio.tests=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/mio)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
