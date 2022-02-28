set(VXL_BUILD_CORE_IMAGING OFF)
if("core-imaging" IN_LIST FEATURES)
  set(VXL_BUILD_CORE_IMAGING ON)
  if(EXISTS "${CURRENT_INSTALLED_DIR}/include/openjpeg.h")
    set(VXL_BUILD_CORE_IMAGING OFF)
    message(WARNING "Can't build VXL CORE_IMAGING features with non built-in OpenJpeg. Please remove OpenJpeg, and try install VXL again if you need them.")
  endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vxl/vxl
    REF dac1c7ed8e183e9c6de8b928c8b0294a7bd1d8ee # v2.0.2
    SHA512 4c6f6dcd793a50cbbc9c7f61c561ed4a747ded67e3dceb09792998c0f0d4294445a441fed668d59297560f196274b1c25593ce67b0aa7597cbb773328e8612c0
    HEAD_REF master
    PATCHES
        fix_dependency.patch
        testlib.patch
)

set(USE_WIN_WCHAR_T OFF)
if(VCPKG_TARGET_IS_WINDOWS)
    set(USE_WIN_WCHAR_T ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVXL_BUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DVXL_BUILD_CORE_IMAGING=${VXL_BUILD_CORE_IMAGING}
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
        -DVXL_USE_GEOTIFF=ON
        -DVXL_USE_WIN_WCHAR_T=${USE_WIN_WCHAR_T}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
# Remove tests which assume that the source dir still exists
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/vxl/vcl/vcl_where_root_dir.h")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/vxl/core/testlib")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/vxl/cmake/VXLConfig.cmake" "${CURRENT_BUILDTREES_DIR}" "") # only used in comment

file(INSTALL "${SOURCE_PATH}/core/vxl_copyright.h" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
