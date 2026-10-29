vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-dr/abcmake
    REF "v6.4.0"
    SHA512 85724b25e158f41f0aa0e5f01ea0530a46f6b4397606b1af115c8aec1c29d317aaaf40a6161795687d713b6f00f66b13a1ab3982f351a139dc79a7d4ac42b7da
)

set(VCPKG_BUILD_TYPE release) # CMake support file only port
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
