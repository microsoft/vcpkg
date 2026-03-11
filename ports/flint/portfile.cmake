
vcpkg_download_distfile(ARCHIVE
    URLS "https://flintlib.org/download/flint-${VERSION}.zip"
    FILENAME "flint-${VERSION}.zip"
    SHA512 a4180c4a8ce889d552e207f699d1243bb9af3001aee5f084bc0f67d04cb788268a31725ba23ffa750b1726cd7756ad4efa9f38b5242960fe962bebe96600e7d8
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-cmakelists.patch
        fix-static.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -DPYTHON_EXECUTABLE=${PYTHON3}
            -DWITH_NTL=OFF
            -DWITH_CBLAS=OFF
    )
    vcpkg_cmake_install()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
else()
    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            --with-ntl=no
            --with-blas=no
    )
    vcpkg_make_install()
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
