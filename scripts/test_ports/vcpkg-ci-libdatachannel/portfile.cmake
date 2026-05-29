set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libdatachannel
    REF v0.23.2
    SHA512 49e19e40874167ef505829841a8b944f8489cb7a15ff6e5a8d74c886c5ff28a32c2724871be2244c805dd6b0919878e06d31c43b27c8d242222adae8509e0d59
    HEAD_REF master
    PATCHES 
        cmake-project.diff
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}/examples/streamer")
vcpkg_cmake_build()
