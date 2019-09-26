# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lava/matplotlib-cpp
    REF f4ad842e70cc56a38f3e4cd852968c7c1cecc9a7
    SHA512 433eb2bc60aa65b9bc40310d7a55b728737e59aafe13e06ddf1a71b25e3cc365cd10f64121fba936180c98eaf5c96dfaf2547e0e3c0daef0b808d1527a37cc17
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/matplotlibcpp.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
