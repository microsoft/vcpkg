set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# https://github.com/ocornut/imgui/tree/v1.92.5/examples/example_glfw_wgpu
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF v1.92.6
    SHA512 1742eaa4811fc63f4ed3804ecd6970cbc0a960c85014903e302ab082ccf7ff7488d534bd4cb7a6d7c2a71824cb80d6c9923ea5a4951190941121cf1b05e3df9d
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
