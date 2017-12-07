#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onqtam/doctest
    REF 1.2.6
    SHA512 bee59e9e18a474b9a7883e0c506a1133fdd382d3ecbe010c0402399d6c48572508bfa347a2196908d846e345508c564f758b17c268a19b65968f5c2ff87b25a4
    HEAD_REF master
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/doctest RENAME copyright)

# Copy header file
file(INSTALL ${SOURCE_PATH}/doctest/doctest.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/doctest)
