set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ggml-org/ggml
    REF v0.9.1
    SHA512 c31aeaaba328cd217f34191f1ce87720bb34dc39dc036f2ba8c92710636706f5be2cfcf86dc8c38ec737b020908da0e136447de10e7d9e6db698c812e7d21ae3
    HEAD_REF master
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/examples/test-cmake"
    OPTIONS
        -DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}
    MAYBE_UNUSED_VARIABLES
        PKG_CONFIG_EXECUTABLE
)
vcpkg_cmake_build()
