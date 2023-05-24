#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO g-truc/gli
    REF 779b99ac6656e4d30c3b24e96e0136a59649a869
    SHA512 6e7ab46b7943cb185c8c1f6e45b765f5463e03628973043a0e8b866458ccceb5249f69a2a77b5e69c73f3ace85af96c7b9b2137685ceb6d0fcb67e491a49be69
    HEAD_REF master
    PATCHES
        disable-test.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/gli)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/gli/CMakeLists.txt")

# Put the license file where vcpkg expects it
# manual.md contains the "licenses" section for the project
file(INSTALL "${SOURCE_PATH}/manual.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)