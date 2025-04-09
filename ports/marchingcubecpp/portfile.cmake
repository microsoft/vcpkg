# header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aparis69/MarchingCubeCpp
    REF f03a1b3ec29b1d7d865691ca8aea4f1eb2c2873d
    SHA512 879204bbfe6a9ad6a6b050b2ba5126884e0b7d01c883d7319dc1deed0c3f6d1658493ba4b39bfcce8c9643739e812d2d69cdbd9be92cd728e0fcccfeb64f898e
)

# Install source files
file(INSTALL 
        "${SOURCE_PATH}/MC.h"
        "${SOURCE_PATH}/noise.h"
     DESTINATION 
        "${CURRENT_PACKAGES_DIR}/include/${PORT}"
)

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md")
