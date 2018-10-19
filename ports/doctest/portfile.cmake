#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onqtam/doctest
    REF 2.0.0
    SHA512 ad167201fa10890e868fab628d73588e66470fbf6d5bdf0cd4e4ce13510f0727411fa709eb748eb1b5de19307c75d2efbcd71cb678e3ef1d0632056d7af2f012
    HEAD_REF master
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/doctest RENAME copyright)

# Copy header file
file(INSTALL ${SOURCE_PATH}/doctest/doctest.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/doctest)
