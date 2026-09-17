vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/TA-Lib/ta-lib/releases/download/v${VERSION}/ta-lib-${VERSION}-src.tar.gz"
    FILENAME "ta-lib-${VERSION}-src.tar.gz"
    SHA512 bc75fba8915c774b37d7456e4a0739549e691ba56cb92b2cccb73a14351ba0eef15118333868ffe24c919f11cfb76977a0b10feaf472b40eaa2c2df0a43e8f8c
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" TALIB_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_DEV_TOOLS=OFF
        -DBUILD_STATIC_LIBS=${TALIB_BUILD_STATIC}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/ta-lib-static.lib" "${CURRENT_PACKAGES_DIR}/lib/ta-lib.lib")
    if(NOT VCPKG_BUILD_TYPE)
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/ta-lib-static.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/ta-lib.lib")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
