vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO clMathLibraries/clFFT
    REF v2.12.2
    SHA512 19e9a4e06f76ae7c7808d1188677d5553c43598886a75328b7801ab2ca68e35206839a58fe2f958a44a6f7c83284dc9461cd0e21c37d1042bf82e24aad066be8
    HEAD_REF master
    PATCHES
        tweak-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
    OPTIONS
        -DBUILD_LOADLIBRARIES=OFF
        -DBUILD_EXAMPLES=OFF
        -DSUFFIX_LIB=
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/clFFT)
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION ${CURRENT_PACKAGES_DIR}/share/clfft/copyright)
