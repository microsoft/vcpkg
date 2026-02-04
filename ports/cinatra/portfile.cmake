set(VCPKG_BUILD_TYPE "release") # header-only port
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/cinatra
    REF ${VERSION}
    SHA512 43d0fffade96f3d187045e20dc61f4cf4f2aaba0ea4b6e54c145d2ef9a9aa67b06538f4c1817f4ad5cc8c1e68dfc5fcb460e376d45ae6ebde9b4fde4498b8637
    HEAD_REF master
)

# Install Cinatra’s headers
file(INSTALL
    "${SOURCE_PATH}/include/cinatra"
    "${SOURCE_PATH}/include/cinatra.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
