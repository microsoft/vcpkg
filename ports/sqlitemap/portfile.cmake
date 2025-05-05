set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bw-hro/sqlitemap
    REF "v${VERSION}"
    SHA512 40e6149d16f7d4ed4f0ff935914f6ba83099fcefc89c017963a006f380bb1d46949da8296d8f670f798b1549d532071c0fd449ecd42230467913b603be5bb4e6
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
