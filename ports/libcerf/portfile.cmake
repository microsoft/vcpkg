if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(BUILD_SHARED_LIBS ON)
else()
  set(BUILD_SHARED_LIBS OFF)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://jugit.fz-juelich.de/mlz/libcerf/uploads/924b8d245ad3461107ec630734dfc781/libcerf-1.13.tgz"
    FILENAME "libcerf-1.13.tgz"
    SHA512 4df711d3e9fd00de99959c3253a9565d1dc2c41f75a5800ced9c52f89cbd13185fbdca3ad75de788fd16c044082738ab345b7fb6a8820ac588edafe1812944aa
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES 001-fix-static-build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCERF_CPP=ON
        -DLIB_MAN=OFF
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libcerf RENAME copyright)

vcpkg_fixup_pkgconfig()
