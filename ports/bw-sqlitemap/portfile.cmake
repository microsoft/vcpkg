set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bw-hro/sqlitemap
    REF "v${VERSION}"
    SHA512 1f3e3fd0c3127273c5aa13b739f5a75c0e84c54a0da20f27793627602f7072b206a53c5dc617ebe89ce87e811ac940e7416109d4bc404e760dbcb2765e28948e
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSM_BUILD_EXAMPLES=OFF
        -DSM_BUILD_TESTS=OFF
        -DSM_ENABLE_COVERAGE=OFF
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
