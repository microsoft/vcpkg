set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Thalhammer/jwt-cpp
    REF "v${VERSION}"
    SHA512 b6fdb93e3f2f065a2eb45fe16cb076a932b8d4bfad2251bd66d2be40d8afaf5c27a9cf17aaea61d8bfa3f5ff9ed3b45f90962dc14d72704ac5b9d717c12cc79f
    HEAD_REF master
    PATCHES
        external-json.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/include/picojson")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DJWT_BUILD_EXAMPLES=OFF
        -DJWT_CMAKE_FILES_INSTALL_DIR=share/${PORT}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
