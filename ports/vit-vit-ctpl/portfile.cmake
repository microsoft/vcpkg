# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vit-vit/ctpl
    REF "ctpl_v.${VERSION}"
    SHA512 5ab83a342e70559687c15f9ab8e7ca47d609713d64bf4248f05b9f311fddb44502ccd54d8352193c00ae570ebde3ea1149389ecdd0207ef46325eb8b648fb0e3
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        lockfree WITH_LOCKFREE
)

if(WITH_LOCKFREE)
    file(INSTALL "${SOURCE_PATH}/ctpl.h"
        DESTINATION "${CURRENT_PACKAGES_DIR}/include")
endif()

file(INSTALL "${SOURCE_PATH}/ctpl_stl.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
