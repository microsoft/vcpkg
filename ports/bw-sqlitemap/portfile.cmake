set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bw-hro/sqlitemap
    REF "v${VERSION}"
    SHA512 72e5dc25d82d440d0da17a5f464750320626b19a39536c268b3591b3f9a0631b2a2bbd6ecc5c242cd69ff9895c49e69ad20f273313a78f837d6e8bb55942217c
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
