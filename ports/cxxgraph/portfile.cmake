set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ZigRazor/CXXGraph
    REF "v${VERSION}"
    SHA512 a4409c81132e6c7e34022c54d9a57b965970aa8e1fcd97b9f916334c1d480674a526e7d5ad727ab652e4842083249dea89de519b104c1f9f205423eabd3c2338
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
# cxxgraph provides no targets and is a header only lib designed to be copied to include dir
file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/cxxgraph")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/cxxgraph" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

