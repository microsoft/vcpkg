include(vcpkg_common_functions)

set(LIBGD_VERSION 2.2.4)
set(LIBGD_HASH 02ce40c45f31cf1645ad1d3fd9b9b498323b2709d40b0681cd403c11072a1f2149f5af844a6bf9e695c29e3247013bb94c57c0225a54189d728f64caf0a938ee)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libgd-gd-${LIBGD_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libgd/libgd/archive/gd-${LIBGD_VERSION}.tar.gz"
    FILENAME "gd-${LIBGD_VERSION}.tar.gz"
    SHA512 ${LIBGD_HASH})

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-fix-cmake.patch"
            "${CMAKE_CURRENT_LIST_DIR}/0002-export-cmake-targets.patch")

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

# Fix up paths on debug config
file(READ ${CURRENT_PACKAGES_DIR}/debug/share/libgd/libgd-config-debug.cmake GD_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" GD_DEBUG_MODULE "${GD_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libgd/libgd-config-debug.cmake "${GD_DEBUG_MODULE}")
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libgd/libgd-config.cmake ${CURRENT_PACKAGES_DIR}/share/libgd/libgd-config.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libgd/libgd-config-release.cmake ${CURRENT_PACKAGES_DIR}/share/libgd/libgd-config-release.cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)