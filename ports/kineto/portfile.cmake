set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/kineto
    REF b2103f78d13fde4937af010c0ef8e24313568bc5
    SHA512 27d9f6a8b27434e83d26ed182df1fecec1d02fc26906995e44155562a730f998f527aad3d6c8a37212255c5e2f86a607a9648edf62861f56eb2ea512c4452908
    HEAD_REF main
)

# Install headers flat (code uses #include <libkineto.h> directly)
file(INSTALL "${SOURCE_PATH}/libkineto/include/"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Provide cmake config
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-kineto-config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-kineto/unofficial-kineto-config.cmake"
    @ONLY
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
