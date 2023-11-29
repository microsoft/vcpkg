vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kfrlib/kfr
    REF ${VERSION}
    SHA512 2bd1c7d47c5e6a25ecfb95183734cd18d37d6a0d02d576cce6ec6184728e9fc0a38b3af08380a9c6e06c3934fcf3156e3c742d8901922d83f6dd75d9d96c2b70
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        capi KFR_ENABLE_CAPI_BUILD
        dft KFR_ENABLE_DFT
        dft-np KFR_ENABLE_DFT_NP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_TESTS=OFF
        -DENABLE_EXAMPLES=OFF
        -DKFR_ENABLE_ASMTEST=OFF
        -DKFR_REGENERATE_TESTS=OFF
        -DKFR_EXTENDED_TESTS=OFF
        -DKFR_SKIP_TESTS=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
