set(VCPKG_BUILD_TYPE "release") # header-only port
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/cinatra
    REF ${VERSION}
    SHA512 1432a5d799736469c34faffec540c5908484e5581edaceb1f809fce619fb357b182f8a6a1e7f814d2ba81ae94d31bfda30923af61ee557449363ef7cc084a902
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH IGUANA_SOURCE_PATH
    REPO qicosmos/iguana
    REF 1.0.9
    SHA512 278d96bc3586104904c91bd62c5579b1db6a844ab5ef64ba3853f55bd04852cf7c035e4c88211bbab3348fba662edab5e6fd1df0d113d41cfed7b455467f9fb3
    HEAD_REF master
)

# Install Cinatra’s headers
file(INSTALL
    "${SOURCE_PATH}/include/cinatra"
    "${SOURCE_PATH}/include/cinatra.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

# Install Iguana’s headers
file(INSTALL
    "${IGUANA_SOURCE_PATH}/include/iguana"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/iguana"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
