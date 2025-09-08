set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libdatachannel
    REF v0.22.4
    SHA512 738bfa45b804cab178426301f97674af4d04b253f45c3caa41b9ec8f658672662e9a7e37a61ee1523b724f3888df85ece86105ae3951aac65a0f2b17fc5b4fac
    HEAD_REF master
    PATCHES 
        cmake-project.diff
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}/examples/streamer")
vcpkg_cmake_build()
