#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF b6c531f7c159a685eb71ad6a93d8308793a4f61b
    SHA512 aa7d6e3f25285dcfea8b2037745e960821f66644a102e06a637b2f84317165a5a11e6a677d60b378fcccf6d00b32abed51fcf3661518830cd29ce36f2ff323bd
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
