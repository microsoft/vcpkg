#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF 1212beae777dba02c230ece8c0c0ec12790047ea
    SHA512 754d0adf32cea1da759be9adb8a64c301ae1cb8556853411bcea4c400079e8e310f1fb8d03f1f26f81553eab24b75fea24a67b9b51d8d92bb4f266e155938230
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
