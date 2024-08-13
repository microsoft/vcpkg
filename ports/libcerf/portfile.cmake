vcpkg_download_distfile(ARCHIVE
    URLS "https://jugit.fz-juelich.de/mlz/libcerf/uploads/924b8d245ad3461107ec630734dfc781/libcerf-${VERSION}.tgz"
    FILENAME "libcerf-${VERSION}.tgz"
    SHA512 4df711d3e9fd00de99959c3253a9565d1dc2c41f75a5800ced9c52f89cbd13185fbdca3ad75de788fd16c044082738ab345b7fb6a8820ac588edafe1812944aa
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if(VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # missing exports
endif()

if(VCPKG_TARGET_IS_UWP)
    set(configure_opts WINDOWS_USE_MSBUILD)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    ${configure_opts}
    OPTIONS
        -DCERF_CPP=ON
        -DLIB_MAN=OFF
        -DLIB_RUN=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
