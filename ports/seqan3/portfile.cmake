#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO seqan/seqan3
    REF 8c8786eae1a1140595aa877d2923515990c92d62
    SHA512 650f2637243b4a475ffec33ab25981ef215b5a14fabccd6df365be450785176d9ee464920c1860b47bc78bc3c970665a949fff7e709dfd7dda5458438d46f66a
    HEAD_REF master
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/seqan3 RENAME copyright)

# Copy the asio header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")