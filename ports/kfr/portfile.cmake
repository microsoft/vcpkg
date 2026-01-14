vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kfrlib/kfr
    REF "${VERSION}"
    SHA512 5cd65ee75a0526d4be6923e25cf3adcf91083192f4e81248205c6822e230c36590a281bf65a1421f21bb842548b7522093dc8e36a375ee7b74aac11170dbc55a
    HEAD_REF main
    PATCHES
        fix-alac-dep.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        capi KFR_ENABLE_CAPI_BUILD
        dft KFR_ENABLE_DFT
        audio KFR_ENABLE_AUDIO
        io KFR_ENABLE_IO
        dsp KFR_ENABLE_DSP
	dsp KFR_USE_BOOST
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

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

list(LENGTH FEATURES features_len)
if(features_len EQUAL 1 AND FEATURES STREQUAL "core")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
endif()

vcpkg_install_copyright(
    COMMENT [[
KFR is distributed under dual GPLv2/v3 and commercial license.
https://kfrlib.com/purchase
]]
    FILE_LIST "${SOURCE_PATH}/LICENSE.txt"
)
