vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmannett85/arg_router
    REF v${VERSION}
    HEAD_REF main
    SHA512 0348a39c0e091b1b0d6887528f6d48372162ed2526fb81935761cf93ff006fc685bbf834d44cea60cdaf4d8b2e947b6cb1a81c901c02aaba68a0dfd16a12ca20
)

set(VCPKG_BUILD_TYPE release) # header-only port
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINSTALLATION_ONLY=ON
)

vcpkg_cmake_install()
vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE"
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_cmake_config_fixup(
    PACKAGE_NAME arg_router
)

file(REMOVE "${CURRENT_PACKAGES_DIR}/include/arg_router/LICENSE"
            "${CURRENT_PACKAGES_DIR}/include/arg_router/README.md"
)

