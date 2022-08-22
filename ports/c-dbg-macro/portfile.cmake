# single header file library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eerimoq/dbg-macro
    REF 78b7655bd0cfc2389fe96a3b6584d2930eb7ebd7
    SHA512 f755c8cf17b422f43f09dcd4f8232b6130a5933d0ce537ce4874ecb886ad2fd5dee26fe12c10cb1554a3720a1263d0ce07252c0893de395b8c9042c9330e60be
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/dbg.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
