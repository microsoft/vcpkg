#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onqtam/doctest
    REF 2.2.0
    SHA512 edf35be338194c7abfb991e6bcc766fe9badc1cc0f21dd7147a6a42ecf451ef6a4eaa1e63b46337fb14a8ed9b107fd381e1b3b502039d7d23476b3f52b12d89c
    HEAD_REF master
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/doctest RENAME copyright)

# Copy header file
file(INSTALL ${SOURCE_PATH}/doctest/doctest.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/doctest)
