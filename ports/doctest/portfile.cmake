#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onqtam/doctest
    REF 1.2.0
    SHA512 7e01e4b817e2200fcd7216342b184ddb60723180bb0a69e24d8c54b7b7d5d983bbd7a2fb0c629e87c95127f4213cca11beb95d079880313d2445703e289c23b5
    HEAD_REF master
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/doctest RENAME copyright)

# Copy header file
file(INSTALL ${SOURCE_PATH}/doctest/doctest.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/doctest)
