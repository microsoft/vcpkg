set(VCPKG_BUILD_TYPE "release") # header-only port
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/cinatra
    REF ${VERSION}
    SHA512 41d740da6e046c0a9551625320b6c50663cc0c8e8535dcd9c3dddf7401b96261705a5bf8c3953cbb8e1d1c38049f5de2a554e18608d6032b5eec0fb53f7a4c7e
    HEAD_REF master
)

# Install Cinatra’s headers
file(INSTALL
    "${SOURCE_PATH}/include/cinatra"
    "${SOURCE_PATH}/include/cinatra.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
