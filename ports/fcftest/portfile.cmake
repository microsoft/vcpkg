vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fcf-framework/fcfTest
    REF "v1.2.7"
    SHA512 afccefa455b0fb637b80aca064a2bf808b608c37cc06b615bc12acf67e16a455af6c57842f699dc44d75771475e8e8fa9c928197cbb9a4d2b3a7a65835c4047d
)

file(INSTALL "${SOURCE_PATH}/test.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/fcfTest")
file(INSTALL "${SOURCE_PATH}/share" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

