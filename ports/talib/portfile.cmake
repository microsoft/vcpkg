vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/TA-Lib/ta-lib/releases/download/v${VERSION}/ta-lib-${VERSION}-src.tar.gz"
    FILENAME "ta-lib-${VERSION}-src.tar.gz"
    SHA512 71ee11166006f3a4a6a4fcb4ffc1165fbb70af2b6bf9d0b84d6a3c174279a934f215910a6ac3c46933f8489421c8b866d00c8f8d2c6f0365a3d362997b008182
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
vcpkg_cmake_config_fixup(PACKAGE_NAME ta-lib CONFIG_PATH lib/cmake/ta-lib)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage-accurate")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
