include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libgd/libgd
    REF gd-2.2.4
    SHA512 02ce40c45f31cf1645ad1d3fd9b9b498323b2709d40b0681cd403c11072a1f2149f5af844a6bf9e695c29e3247013bb94c57c0225a54189d728f64caf0a938ee
    HEAD_REF master
    PATCHES
        0001-fix-cmake.patch
        no-write-source-dir.patch
)

#delete CMake builtins modules
file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/modules/CMakeParseArguments.cmake)
file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/modules/FindFreetype.cmake)
file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/modules/FindJPEG.cmake)
file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/modules/FindPackageHandleStandardArgs.cmake)
file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/modules/FindPNG.cmake)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(LIBGD_SHARED_LIBS ON)
  set(LIBGD_STATIC_LIBS OFF)
else()
  set(LIBGD_SHARED_LIBS OFF)
  set(LIBGD_STATIC_LIBS ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DENABLE_PNG=ON
            -DENABLE_JPEG=ON
            -DENABLE_TIFF=ON
            -DENABLE_FREETYPE=ON
            -DENABLE_WEBP=ON
            -DENABLE_FONTCONFIG=ON
            -DBUILD_SHARED_LIBS=${LIBGD_SHARED_LIBS}
            -DBUILD_STATIC_LIBS=${LIBGD_STATIC_LIBS}
)

vcpkg_build_cmake()
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libgd)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libgd/COPYING ${CURRENT_PACKAGES_DIR}/share/libgd/copyright)
