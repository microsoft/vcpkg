
vcpkg_download_distfile(ARCHIVE
    URLS "https://flintlib.org/download/flint-${VERSION}.zip"
    FILENAME "flint-${VERSION}.zip"
    SHA512 e6eca3e9055dd11b02d6d6234ac31605380fe5d7ac959c4ef1192661e282df7457a5be3e6a54aa1c8a4d82d0027dd2186002362c66b0bb5e984604ccf4a657af
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(PYTHON3)
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            "-DPython_EXECUTABLE=${PYTHON3}"
            -DVCPKG_LOCK_FIND_PACKAGE_CBLAS=OFF
            -DWITH_NTL=OFF
    )
    vcpkg_cmake_install()
    vcpkg_copy_pdbs()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/flint)
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
