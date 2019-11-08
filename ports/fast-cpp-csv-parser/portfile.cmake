# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ben-strasser/fast-cpp-csv-parser
    REF 78f413248fdeea27368481c4a1d48c059ac36680
    SHA512 f8eb477e0b5e82f5b5d7bdf045094dcc59433e7b6305a1e16e45c2c24f4bbb7f6e9540e17a8ffafce29ea2ebe3a2647174824abe80da5f2054f7df3d7da8c28d
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/csv.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
