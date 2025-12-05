set(VCPKG_BUILD_TYPE "release") # header-only port
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/cinatra
    REF ${VERSION}
    SHA512 df34917c98c38c615215bde71139d91fd128d823561fa6915229c59032849544ae9fadcb3ceba006511a38389c2427018cf97a0038d8bd9632dea95f2fcfaad3
    HEAD_REF master
)

# Install Cinatra’s headers
file(INSTALL
    "${SOURCE_PATH}/include/cinatra"
    "${SOURCE_PATH}/include/cinatra.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
