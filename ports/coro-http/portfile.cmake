vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harvestsure/coro-http
    REF "v${VERSION}"
    SHA512 072951e3fe1f609df470ffc69e0746a3d70c11dbff7dfecd9d06344df3bf4be5a756c764358ed2e5df13a31fd0278ecf95cd00ee972f53928a7529062310f42e
    HEAD_REF main
)

# For header-only library, just copy headers
file(COPY "${SOURCE_PATH}/include/coro_http" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Install CMake config files to the correct location
file(COPY "${SOURCE_PATH}/cmake/coro_httpConfig.cmake.in" DESTINATION "${CURRENT_PACKAGES_DIR}/share/coro_http/cmake")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
