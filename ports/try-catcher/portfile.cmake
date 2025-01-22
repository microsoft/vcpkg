vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO daleabarnard/try-catcher
    REF 1.0.1
    SHA512 560edd0841c9a85bbef61fb4ad4e76314f04b566586d2990a0c582a67259803350a217ad3dacc1401917d23a2c929b1529e0a1e717f707480b6240e953ed8155
    HEAD_REF main
)

# This is a header-only modern C++ package.
file(INSTALL "${SOURCE_PATH}/TryCatcher.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
