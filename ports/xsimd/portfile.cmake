# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xsimd
    REF 81af3b629097dd257b74f31f4152e3d5cda73c9b # 7.4.6
    SHA512 2d72af93a8166bca04203ec305a1bafb918efb12fb39cd518f7c9fd89b6c1512157ea06f5ef94a08ee4a09066425100c77c4a61f1940b5bf22ac18d6a034cb56
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
