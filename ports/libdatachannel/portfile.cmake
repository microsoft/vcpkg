vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Nemirtingas/libdatachannel
    REF cxx14
    SHA512 7c20fbd308339405b5bc3c8c9d15c17f031a569849bf586eff087dea38a10c5bed84cb80cafd6b39d8ce45d78f575516bf3479bf9cc861c0d7d05afc3067eb96
    HEAD_REF master
    PATCHES
        fix-for-vcpkg.patch
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
