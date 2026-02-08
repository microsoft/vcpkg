vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harvestsure/coro-http
    REF "v${VERSION}"
    SHA512 1f48fac6e6d66ad00cc89fa7518bb8e34b69fa5bdd522c46e60708868beac67f04037ec6fb39e17f58b153f884182b40433ee52fa22d1f3a0be3e5d2daa6ccaa
    HEAD_REF main
)

# For header-only library, just copy headers
file(COPY "${SOURCE_PATH}/include/coro_http" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Install CMake config files to the correct location
file(COPY "${SOURCE_PATH}/cmake/coro_httpConfig.cmake.in" DESTINATION "${CURRENT_PACKAGES_DIR}/share/coro_http/cmake")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
