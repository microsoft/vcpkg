set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Thalhammer/jwt-cpp
    REF "v${VERSION}"
    SHA512 e88ef8007a19821679c3d60cc02af38e4c07fed3ae589167617353bcb1823eb90f0893183083ccf414d2da38a1b0ac5a9cc7eb1c25e622e4c8ce004a48da24fc
    HEAD_REF master
    PATCHES
        picojson_from_vcpkg.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/include/picojson")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        picojson JWT_DISABLE_PICOJSON
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DJWT_EXTERNAL_PICOJSON=ON
        -DJWT_BUILD_EXAMPLES=OFF
        -DJWT_CMAKE_FILES_INSTALL_DIR=share/${PORT}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
