set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Thalhammer/jwt-cpp
    REF "v${VERSION}"
    SHA512 9a2725228565d671e065a4647dad38f36251a4ee07c796cac35252557134a20c2dc260f62c011438c7fbde57f5c511bb0096569512c0aebdae048c7a626805b7
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
