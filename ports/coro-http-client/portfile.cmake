vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harvestsure/coro-http-client
    REF "v${VERSION}"
    SHA512 198542e84ce63342b0c69e9c095e809a427a578255cf678901c92c4a87093e8629c74c8cd6aabcec3fa29a3ed1b83677443785f5fc93956647879a34fe9b8d32
    HEAD_REF main
)

# For header-only library, just copy headers
file(COPY "${SOURCE_PATH}/include/coro_http" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Install CMake config files to the correct location
file(COPY "${SOURCE_PATH}/cmake/coro_httpConfig.cmake.in" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
