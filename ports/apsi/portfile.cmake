vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/APSI
    REF "v${VERSION}"
    SHA512 c3fb58ce96f3c11b1f1e511fa649006935a75022e9818a871c606ff60c7fbf1aaae2c469e6190b32a23562e319cd1c07d97223153fdd9faeaba55655d1a35fe9
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        zeromq APSI_USE_ZMQ
)

# APSI probes for AVX support by running a test program, which a cross-build cannot do. The
# probe is reached only on AMD64, where the vendored FourQ can use the extensions; elsewhere
# architecture detection is a compile-only check and needs no help.
set(CROSSCOMP_OPTIONS "")
if(VCPKG_CROSSCOMPILING AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(CROSSCOMP_OPTIONS -DHAVE_AVX_EXTENSIONS_EXITCODE=0 -DHAVE_AVX2_EXTENSIONS_EXITCODE=1)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAPSI_BUILD_TESTS=OFF
        -DAPSI_BUILD_CLI=OFF
        ${FEATURE_OPTIONS}
        ${CROSSCOMP_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/APSI")

# Upstream installs LICENSE and NOTICE under share/licenses/APSI. vcpkg's canonical
# location is share/apsi/copyright, which vcpkg_install_copyright writes from those same two
# files below, so drop upstream's copy along with the debug/share it would otherwise leave.
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/licenses"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/NOTICE")
