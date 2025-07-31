set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ggml-org/ggml
    REF 44ea6eda2ad8a94663597cbe85e37de98bd99269
    SHA512 be93d44f87ef25f7c0bb37ca8020de7714ec89b4f92677d7b631a2dcad9db38789e59adb7a6af0d1f5f550c570d875ea9ed69833f7d7af76ef8cb9159f0a7c23
    HEAD_REF master
    PATCHES
        android-vulkan.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/examples/test-cmake"
)
vcpkg_cmake_build()
