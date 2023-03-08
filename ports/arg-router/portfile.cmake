vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmannett85/arg_router
    REF v${VERSION}
    HEAD_REF main
    SHA512 7f19f9b4df8c2b8968cfc05a92eb3dab44fdc261835a75ccf6e0ec64c68059f05fd7125466e81fa8b04638ab79792b2151216214bb121c06c77c4441a6917315
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

