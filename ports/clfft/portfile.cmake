set(BUILD_SHARED_VALUE ON)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
	set(BUILD_SHARED_VALUE OFF)
endif()
set(CRT_STATIC_LIBS_VALUE OFF)
if(VCPKG_CRT_LINKAGE STREQUAL "static")
	set(CRT_STATIC_LIBS_VALUE ON)
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO clMathLibraries/clFFT
    REF v2.12.2
    SHA512 19e9a4e06f76ae7c7808d1188677d5553c43598886a75328b7801ab2ca68e35206839a58fe2f958a44a6f7c83284dc9461cd0e21c37d1042bf82e24aad066be8
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/src
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_VALUE}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_VALUE}
        -DLINK_CRT_STATIC_LIBS=${CRT_STATIC_LIBS_VALUE}
        -DBUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/clFFT")

vcpkg_copy_pdbs()