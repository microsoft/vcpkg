vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO msteinbeck/tinyspline
    REF "v${VERSION}"
    SHA512 e81d95e9fa7ec33b70d541695ab18b8e9c2a92e7c66877aa9957526e2ac144558b47409e1a1b721f7702a8462a22f360d1ec96b0023db108da13f8c37b8c0c20
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTINYSPLINE_BUILD_EXAMPLES=OFF
        -DTINYSPLINE_BUILD_TESTS=OFF
        -DTINYSPLINE_BUILD_DOCS=OFF
        -DTINYSPLINE_WARNINGS_AS_ERRORS=OFF
        -DTINYSPLINE_INSTALL_LIBRARY_DIR=lib
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tinyspline DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME tinysplinecxx CONFIG_PATH lib/cmake/tinysplinecxx)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
