set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vincentlaucsb/classify_scalar
    REF ${VERSION}
    SHA512 2a699c20519a1c69594e090a82948c776861aab04372f678a690401b239d4c3ea82c72d6417fda04c2de7424803d8a6e6a4bba57cc3ee9a1bb960518d9e16344
    HEAD_REF main
)

file(INSTALL ${SOURCE_PATH}/include/classify_scalar.hpp  DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
