vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmannett85/arg_router
    REF v${VERSION}
    HEAD_REF main
    SHA512 b14f4fadf93ee405d3a0da919c74a5c7e83e012a811246802b05114f466b1d15031c8b912d064d0ea29b3cb86c1bd8fe184e9c80e1700b230e1880f94f204971
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

