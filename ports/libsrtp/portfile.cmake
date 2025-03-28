vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cisco/libsrtp
    REF "v${VERSION}"
    SHA512 eb42cc1755acd5677351fc058e2f45314ba66b590bce80944ea12aa3780953ce4c1c6211979729304d753e6c0fd325647adafc38c20c6af8482ce6f552022896
    PATCHES
        fix-runtime-destination.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl ENABLE_OPENSSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -DLIBSRTP_TEST_APPS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libSRTP)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
