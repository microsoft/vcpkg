set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ZigRazor/CXXGraph
    REF "v${VERSION}"
    SHA512 81af9edbb3d768bf770a3626b411c753632763a1229fe87dbdca7c8d8f96554205abf527f0916bfe6dff47b5c19259345f2f9cad81bc84eb4d7972de75643af4
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
# cxxgraph provides no targets and is a header only lib designed to be copied to include dir
file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
