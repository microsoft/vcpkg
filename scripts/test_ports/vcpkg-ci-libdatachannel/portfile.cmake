set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libdatachannel
    REF v0.21.2
    SHA512 fd0d66bb932e29abc01e9f1a8b16ccb79012a7e3901e2e0f882f56ab2f090260945e1556c85ad07ef897b8c70fcdd44cdeead9955a9bca7afe1dda8900c473cc
    HEAD_REF master
    PATCHES 
        cmake-project.diff
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}/examples/streamer")
vcpkg_cmake_build()
