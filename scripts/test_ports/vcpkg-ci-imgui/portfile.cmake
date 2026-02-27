set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# https://github.com/ocornut/imgui/tree/v1.92.5/examples/example_glfw_wgpu
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF v1.92.5
    SHA512 382b862a285464bd311c79a0ff07885e42300d79704bb65cd1cbbf35cef63f7f50784ed23f7479e4490bbaae0d23ea1b2b067a3571e0b442d390824f9611bd59
    HEAD_REF master
    PATCHES
        # use find_package(imgui) instead of source file list
        fix-examples.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/examples/example_glfw_wgpu"
    OPTIONS
        "-DIMGUI_DAWN_DIR=${CURRENT_INSTALLED_DIR}"
)
vcpkg_cmake_build()
