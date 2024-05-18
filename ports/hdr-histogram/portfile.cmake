vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO HdrHistogram/HdrHistogram_c
    REF ${VERSION}
    SHA512 2ede4b8412c4f0070d555515498e163397de5edebe7560eaea13adcb95a52b7fea99686aed06bbca0c6e8afdf65715483c3889d750f6b5b727bcf43c4fbe18d4
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        # Do not build tests and examples
        -DHDR_HISTOGRAM_BUILD_PROGRAMS="OFF"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME hdr_histogram
    CONFIG_PATH lib/cmake/hdr_histogram
)

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt" "${SOURCE_PATH}/COPYING.txt")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
