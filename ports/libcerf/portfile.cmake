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

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES 001-fix-static-build.patch
)

if(VCPKG_TARGET_IS_UWP)
    set(configure_opts WINDOWS_USE_MSBUILD)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    ${configure_opts}
    OPTIONS
        -DCERF_CPP=ON
        -DLIB_MAN=OFF
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libcerf" RENAME copyright)

vcpkg_fixup_pkgconfig()
