vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libdatachannel
    REF 655175d21e58281031c940a94042d5d1fd46efb3 # v 0.12.2
    SHA512 e1e228bf720ef57130fbb9cc33310cebbdbd16c001455cd56e8746b6ee41bac56da5e5a90235e0a826b52711dc3c95b9d9f56d9e406999f9fd384aee2892578d
    HEAD_REF master
    PATCHES
        fix-for-vcpkg.patch
        CXX17_ADAPTOR_TYPEDEFS_DEPRECATION_WARNING.patch # submitted upstream as https://github.com/paullouisageneau/libdatachannel/pull/413
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        stdcall CAPI_STDCALL
    INVERTED_FEATURES
        ws NO_WEBSOCKET
        srtp NO_MEDIA
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DUSE_SYSTEM_SRTP=ON
        -DNO_EXAMPLES=ON
        -DNO_TESTS=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/libdatachannel)
vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
