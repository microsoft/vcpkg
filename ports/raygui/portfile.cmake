#header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO raysan5/raygui
    REF "${VERSION}"
    SHA512 09643f3661879a9130122351d0f9310f1ecde5dd1242d15f7b9c61e80dc9acfc3e6b85682ae7079c8579fd39340da8c5dfdea62aabc6cc72a966dea675ddfd38
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/raygui.h"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
