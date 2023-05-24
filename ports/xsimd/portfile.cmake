# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xsimd
    REF "${VERSION}"
    SHA512 bd7a363bbebc9196954c8c87271f14f05ca177569fcf080dac91be06ad2801c43fccbb385afd700b80d58c83d77f26ba199a7105672e4a1e55c517d15dd6e8e3
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        xcomplex ENABLE_XTL_COMPLEX
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_FALLBACK=OFF
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
