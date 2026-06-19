set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lunarmodules/lua-compat-5.3
    REF "v${VERSION}"
    SHA512 0e6bd10513cab6053df7a911ba117c2dd5b5409e75bfe0890ee2ec0122893aa70fc1dc88b10a65553dd1069a038e3c7295dccc2de5c10338eccc718029d3f7b5
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/c-api/compat-5.3.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/c-api/compat-5.3.c" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
