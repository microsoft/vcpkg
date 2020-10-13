# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xsimd
    REF b8c5b02344675825539c56e2d598f41b6ca1ada2 # 7.4.8
    SHA512 7480c64cecee2b2954422dcf44f4f1855777030bc6f612c0fb2c97e822d9589ed7c90eef0f784e20766c7ef28d7297ec838f86ed37193dddccc67bfa2fa41761
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    xcomplex ENABLE_XTL_COMPLEX
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_FALLBACK=OFF
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
