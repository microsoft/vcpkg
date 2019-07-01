#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemtrif/utfcpp
    REF v3.1
    SHA512 826ac7aa61215ac2144fa3f5edc7f291c3dd25dc69b0c82526840f4651f822515ec262915e1117d975e5c5dd729f6166806a5d397262f59a2b323eb7009671f5
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(INSTALL ${SOURCE_PATH}/source/utf8.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/utfcpp RENAME copyright)

# Copy the utf8-cpp header files
file(COPY ${SOURCE_PATH}/source/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
