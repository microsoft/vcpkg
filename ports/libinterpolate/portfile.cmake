vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CD3/libInterpolate
    REF ${VERSION}
    SHA512 25abb4df8ea0648cd9cdd309f2491a9fc2cdbc5af3cc786fec39302680835bb1f29281628dd89323f353d377d9702d9b9f894c85c5cb0aa7cbae5590d05d3e27
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DlibInterpolate_VERSION=${VERSION}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libInterpolate)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
