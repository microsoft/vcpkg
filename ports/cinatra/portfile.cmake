set(VCPKG_BUILD_TYPE "release") # header-only port
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/cinatra
    REF ${VERSION}
    SHA512 c5fcacab1627429fda5d158a12c975a1ce73e49d9fdae3812d581d82ff7d891e63960e7aae1f1bd2cf27259654240cf6f6e0fe3e388a316600b1a7558673422f
    HEAD_REF master
)

# Install Cinatra’s headers
file(INSTALL
    "${SOURCE_PATH}/include/cinatra"
    "${SOURCE_PATH}/include/cinatra.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
