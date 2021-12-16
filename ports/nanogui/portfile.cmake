vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mitsuba-renderer/nanogui
    REF 2d875ad0cd480b8eb01f441e2ef113a258f1effe  # Commits on Nov 24, 2021
    SHA512 353b3449c2bf0a2e8e29aae62626184c36f882efe0c3e2edc8a43951f7053618d4fd996406997957c2ac6500d2b1b070e3396f346dc4e901dbdd167c58ea1bf3
    HEAD_REF master
    PATCHES
        toolchain-features.patch
#       fix-dependencies.patch
#       fix-package-seeking.diff
#       fix-cmakelists.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DNANOGUI_BUILD_EXAMPLES=OFF
        -DNANOGUI_BUILD_PYTHON=OFF
        -DNANOGUI_BUILD_GLAD=OFF
        -DNANOGUI_BUILD_GLFW=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
