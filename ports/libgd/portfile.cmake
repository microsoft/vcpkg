vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libgd/libgd
    REF gd-2.2.5
    SHA512 e4ee4c0d1064c93640c29b5741f710872297f42bcc883026a63124807b6ff23bd79ae66bb9148a30811907756c4566ba8f1c0560673ccafc20fee38d82ca838f
    HEAD_REF master
    PATCHES
        0001-fix-cmake.patch
        no-write-source-dir.patch
        intrin.patch
)

#delete CMake builtins modules
file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/modules/CMakeParseArguments.cmake)
file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/modules/FindFreetype.cmake)
file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/modules/FindJPEG.cmake)
file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/modules/FindPackageHandleStandardArgs.cmake)
file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/modules/FindPNG.cmake)

set(ENABLE_PNG OFF)
if("png" IN_LIST FEATURES)
    set(ENABLE_PNG ON)
endif()

set(ENABLE_JPEG OFF)
if("jpeg" IN_LIST FEATURES)
    set(ENABLE_JPEG ON)
endif()

set(ENABLE_TIFF OFF)
if("tiff" IN_LIST FEATURES)
    set(ENABLE_TIFF ON)
endif()

set(ENABLE_FREETYPE OFF)
if("freetype" IN_LIST FEATURES)
    set(ENABLE_FREETYPE ON)
endif()

set(ENABLE_WEBP OFF)
if("webp" IN_LIST FEATURES)
    set(ENABLE_WEBP ON)
endif()

set(ENABLE_FONTCONFIG OFF)
if("fontconfig" IN_LIST FEATURES)
    set(ENABLE_FONTCONFIG ON)
endif()

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
    OPTIONS -DENABLE_PNG=${ENABLE_PNG}
            -DENABLE_JPEG=${ENABLE_JPEG}
            -DENABLE_TIFF=${ENABLE_TIFF}
            -DENABLE_FREETYPE=${ENABLE_FREETYPE}
            -DENABLE_WEBP=${ENABLE_WEBP}
            -DENABLE_FONTCONFIG=${ENABLE_FONTCONFIG}
            -DBUILD_STATIC_LIBS=${LIBGD_STATIC_LIBS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libgd)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libgd/COPYING ${CURRENT_PACKAGES_DIR}/share/libgd/copyright)
