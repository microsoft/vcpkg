vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO deadlightreal/SwiftNet
    REF 1.0.0
    SHA512 5e13a0ecf0a6a8a58a3f2e8d570ae3668517ad83a9bf3494170238456f0eedcbcba84ce4b366c0961ce5b0bbb97bea489dcad83d043abbe50e4ec6694bb9dcb0
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/src
)

vcpkg_cmake_install()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
