include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vxl/vxl
    REF 7a130cf05e907a6500e3e717297082c46e77f524
    SHA512 b9f7e48e37b44469031c6de1bf2a3d0aa0ecf4d3c2f4dd0d1a84c273ca8a778b48f3caf7ec6ef0f2dea1dc534ebfdb6b2cde47a56d81aa4f0685114c0bda157c
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DVXL_USING_NATIVE_ZLIB=ON
        -DVXL_USING_NATIVE_BZLIB2=ON
        -DVXL_USING_NATIVE_JPEG=ON
        -DVXL_USING_NATIVE_TIFF=ON
        -DVXL_USING_NATIVE_EXPAT=ON
        -DVXL_USING_NATIVE_PNG=ON
        -DVXL_USING_NATIVE_SHAPELIB=ON
        -DVXL_USING_NATIVE_GEOTIFF=ON
        -DVXL_FORCE_V3P_OPENJPEG2=ON
        -DVXL_FORCE_V3P_J2K=ON
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/vxl/cmake)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/core/vxl_copyright.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)