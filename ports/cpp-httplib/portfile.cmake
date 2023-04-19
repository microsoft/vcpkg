# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF v0.12.2
    SHA512 dda47f76eaf5b4daa35f1295e482f1d81dd8823ae06339b9f4c93e4fbe7b54ae28760d3083b5d5cff212f1a679616adfa47dbb9d06c6810fac4b58197f575429
    HEAD_REF master
    PATCHES
        fix-find-brotli.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME httplib CONFIG_PATH lib/cmake/httplib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib" "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
