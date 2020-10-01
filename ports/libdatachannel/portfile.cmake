vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libdatachannel
    REF v0.9.2
    SHA512 7fc43728d3d7be5c088551f399941213b0cfbe6fb712befafe50851ff5495239913fab924dfd653fc202239c226082411ff8c768185f3838631fe7ee00d9e985
    HEAD_REF master
    PATCHES
        fix-for-vcpkg.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    no-ws NO_WEBSOCKET
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNO_EXAMPLES=ON
        -DNO_TESTS=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/libdatachannel)
vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
