#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF 7d78b743e43ecba06ca47426d03d9d16076dec16
    SHA512 2174ad6a1eaced41e00f0781d13e68ca981644c20ba66e8e6e10b75d910203d860a93d3e9875a0560a9b7aee88e5703880014af67ab32028bffebb06f79811b7
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
