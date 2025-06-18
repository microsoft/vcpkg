set(VCPKG_BUILD_TYPE "release") # header-only port
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/cinatra
    REF ${VERSION}
    SHA512 1432a5d799736469c34faffec540c5908484e5581edaceb1f809fce619fb357b182f8a6a1e7f814d2ba81ae94d31bfda30923af61ee557449363ef7cc084a902
    HEAD_REF master
)

# Install only Cinatra’s own headers—not vendored dependencies
file(INSTALL
    "${SOURCE_PATH}/include/cinatra"
    "${SOURCE_PATH}/include/cinatra.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
