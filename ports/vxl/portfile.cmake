include(vcpkg_common_functions)

set(BUILD_CORE_IMAGING OFF)
if("core_imaging" IN_LIST FEATURES)
  set(BUILD_CORE_IMAGING ON)
  if(EXISTS "${CURRENT_INSTALLED_DIR}/include/openjpeg.h")
    set(BUILD_CORE_IMAGING OFF)
    message(WARNING "Can't build VXL CORE_IMAGING features with non built-in OpenJpeg. Please remove OpenJpeg, and try install VXL again if you need them.")
  endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vxl/vxl
    REF v1.18.0
    SHA512 6666d647b2e7010b91cb0b05016b5f49ae46d198f6bd160fe13fc09bc674eff5b937331fa11d81a8496473968b63452d950eee4fc2512152af57304a14bed63f
    HEAD_REF master
    PATCHES
        fix_dependency.patch
)

set(USE_WIN_WCHAR_T OFF)
if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(USE_WIN_WCHAR_T ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_CORE_IMAGING=${BUILD_CORE_IMAGING}
        -DVXL_FORCE_V3P_BZLIB2=OFF
        -DVXL_USING_NATIVE_BZLIB2=TRUE # for disable build built-in bzip2 (v3p/bzlib/CMakeLists.txt#L10-L26)
        -DVXL_FORCE_V3P_CLIPPER=ON # TODO : need add clipper port to turn off
        -DVXL_FORCE_V3P_DCMTK=OFF
        -DVXL_FORCE_V3P_GEOTIFF=OFF
        -DVXL_FORCE_V3P_J2K=OFF
        -DVXL_FORCE_V3P_JPEG=OFF
        -DVXL_FORCE_V3P_OPENJPEG2=ON # TODO : need fix compile error when using openjpeg port to turn off
        -DVXL_FORCE_V3P_PNG=OFF
        -DVXL_FORCE_V3P_TIFF=OFF
        -DVXL_FORCE_V3P_ZLIB=OFF
        -DVXL_USE_DCMTK=OFF # TODO : need fix dcmtk support to turn on
        -DXVL_USE_GEOTIFF=ON
        -DVXL_USE_WIN_WCHAR_T=${USE_WIN_WCHAR_T}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/vxl/cmake)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/core/vxl_copyright.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
#
