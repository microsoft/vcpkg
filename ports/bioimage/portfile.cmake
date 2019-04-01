
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
message("bioimage only supports static linkage")
set(VCPKG_LIBRARY_LINKAGE "static")
endif()

include(vcpkg_common_functions)
vcpkg_from_bitbucket(
   OUT_SOURCE_PATH SOURCE_PATH
   REPO dimin/bioimageconvert
   REF v2.5.2
   SHA512 73d4675ff652bd296e626f0475760ea5ce4b60efa32ce35172faf182bdda90aab62ae019eaccbaf864cae99ed6fea0977891a926ec4519e5205ea21f10d1d006
   HEAD_REF master
   PATCHES
      bioimageconvert.patch
      static-openjpeg.patch
)

set(BIC_ENABLE_OPENCV OFF)
if("opencv" IN_LIST FEATURES)
   set(BIC_ENABLE_OPENCV ON)
endif()

# Built-in FindExiv2 is out of date, remove to force use of config file
file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindLibRaw.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindExiv2.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindGeoTIFF.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindPROJ4.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindEigen3.cmake)


set(CMAKELIST ${SOURCE_PATH}/CMakeLists.txt)
file(READ ${CMAKELIST} _contents)
string(REPLACE "\${BIC_PROJ4_REQUIRED_VERSION}" "" _contents "${_contents}")
string(REPLACE "\${BIC_LIBRAW_REQUIRED_VERSION} " "" _contents "${_contents}")
string(REPLACE "\${BIC_EXIV2_REQUIRED_VERSION} " "" _contents "${_contents}")
string(REPLACE "\${BIC_LCMS2_REQUIRED_VERSION} " "" _contents "${_contents}")
string(REPLACE "\${EXIV2_LIBRARIES}" "exiv2lib" _contents "${_contents}")
string(REPLACE "\${GEOTIFF_LIBRARIES}" "geotiff_library" _contents "${_contents}")
message("Patching: ${CMAKELIST}")
file(WRITE ${CMAKELIST} "${_contents}")

vcpkg_configure_cmake(
   SOURCE_PATH ${SOURCE_PATH}
   PREFER_NINJA
   OPTIONS
      -DBIC_INTERNAL_LIBTIFF=OFF
      -DBIC_INTERNAL_LIBJPEG=OFF
      -DBIC_INTERNAL_LIBGEOTIFF=OFF
      -DBIC_INTERNAL_EXIV2=OFF
      -DBIC_INTERNAL_OPENJPEG=ON
      -DBIC_ENABLE_LIBJPEG_TURBO=OFF
      -DBIC_ENABLE_FFMPEG=OFF
      -DBIC_ENABLE_GDCM=OFF
      -DBIC_ENABLE_JXRLIB=OFF
      -DBIC_ENABLE_LIBWEBP=OFF
      -DBIC_ENABLE_NIFTI=OFF
      -DBIC_ENABLE_QT=OFF
      -DBIC_ENABLE_OPENCV=${BIC_ENABLE_OPENCV}
      -DBIC_ENABLE_OPENMP=OFF
      -DBIC_ENABLE_IMGCNV=OFF
      -DLIBBIOIMAGE_TRANSFORMS=OFF
      #-DZLIB_ROOT=${ZLIB_ROOT}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/LICENCE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/bioimage)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/bioimage/LICENCE.txt ${CURRENT_PACKAGES_DIR}/share/bioimage/copyright)