vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libdatachannel
    REF v0.14.3
    SHA512 21746d1a02aa8eb98a5c9716c12f14048a680f85efab8d8beca02379946bb49858c7ed02e7238f61e94d0aba6d70069136778d78484b88f8d09640c0740e24a3
    HEAD_REF master
    PATCHES
        0001-fix-for-vcpkg.patch
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

file(READ ${CURRENT_PACKAGES_DIR}/share/${PORT}/libdatachannel-config.cmake DATACHANNEL_CONFIG)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/libdatachannel-config.cmake "
include(CMakeFindDependencyMacro)
find_dependency(Threads)
find_dependency(OpenSSL)
find_dependency(libjuice)
${DATACHANNEL_CONFIG}")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
