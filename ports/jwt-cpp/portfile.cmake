set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Thalhammer/jwt-cpp
    REF "v${VERSION}"
    SHA512 1d52816e4d04a50c57e3655e1ebd0fa4e54d03aef49950b800c9c43715cdaceec7a572a02ffff5d358d5f8cde242112da06804fc7a53bc154b3860cf133716a0
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
