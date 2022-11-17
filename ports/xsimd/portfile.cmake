# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xsimd
    REF 9.0.1
    SHA512 ed56287f608ccdf5bc5d5fc2918e313e7c4cecdd9ef2c9993a72ea900d9ff662c57ac5326c7a809eb11505c6f39d4599f3f161b97b6e03c65783b824b8d700d2
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
