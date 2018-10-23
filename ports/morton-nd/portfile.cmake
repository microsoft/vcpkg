#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kevinhartman/morton-nd
    REF v2.0.0
    SHA512 f349187a9c6094ebdc8dc10a0b028e119a82721946e2f629b3f64edade9665a97824d6a52496e470da61e5b65ae46c953346b271c2db11f5f2e3c7748de03daf
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/morton-nd)
file(COPY ${SOURCE_PATH}/NOTICE DESTINATION ${CURRENT_PACKAGES_DIR}/share/morton-nd)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/morton-nd/LICENSE ${CURRENT_PACKAGES_DIR}/share/morton-nd/copyright)

file(GLOB HEADER_FILES ${SOURCE_PATH}/morton-nd/include/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/morton-nd)
