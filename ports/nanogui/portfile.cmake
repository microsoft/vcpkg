vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mitsuba-renderer/nanogui
    REF c6505300bb3036ec87ac68f5f1699c434c3d7fc6  # Commits on Feb 15, 2022
    SHA512 297a7bc6e4388b1dd66950073ef0d82c16aabc6ec4df3e78da1514339809e3c99189697dc5ae2c6eb5b840420339b010b59117d02117c97bbde4939f2638ea7a
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
