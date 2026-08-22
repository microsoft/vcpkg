set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF be374fa598aae658ea43f843a6d821b2957d4a83 # 2026-06-24
    SHA512 1db92d036a0505389d6259dd5afe4638acc1747554378dfbcb730f8b8b843b9007fbce2046845eccff51aa552adf82a3cd4fb454d834cef95b04ed687bcb4a17
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
