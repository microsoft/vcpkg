#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF d846fe50a3f0bb7767c7e087a05f4be95f4da0ec
    SHA512 83560cb0c39b6a4781e916c6081ad2728296e1b19760ca1b6426a8431fb6d7093760a882c539dd77152f5892fe081b1795af6366ea91385bb10aba6adf27170f
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
