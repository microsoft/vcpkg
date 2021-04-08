# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xsimd
    REF 0c8e9e7b67369003ba291a3df8060d605ae3bd4f # 7.4.9
    SHA512 6c22c3a349ff1aa495d0aa66c0159539e10e1b9418eb4c4b7b1b42ce36a8a33e87cc93484daadae7b837f72fb20429ef50461316c6107b2b68c969323d68bcf9
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
