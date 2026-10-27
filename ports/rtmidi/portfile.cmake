# Upstream uses CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS, which causes issues
# https://github.com/thestk/rtmidi/blob/4.0.0/CMakeLists.txt#L20
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thestk/rtmidi
    REF "${VERSION}"
    SHA512 4f557581a61765ee4114e8f33c6e0c8849fa575ab7a5507ff711f799dbb284743e309823763d2b5509c14cf86278c3c03a375574a8491a45f0e6d51a144888b8
    HEAD_REF master
    PATCHES
        fix-build-testing.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        alsa RTMIDI_API_ALSA
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRTMIDI_API_JACK=OFF
        -DRTMIDI_BUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
