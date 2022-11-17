vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dobiasd/frugally-deep
    REF v0.15.10-p0
    SHA512 e665df59c83fea5fc0a89158639c83f9c72cba1fc8c61086032db60c395606dab4e9085f1380714e4f8a82c1f2b143aa22ff6212d9180c368283e1965e6dea87
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        double FDEEP_USE_DOUBLE
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DFDEEP_BUILD_UNITTEST=OFF
    -DFDEEP_USE_TOOLCHAIN=ON
    ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/frugally-deep TARGET_PATH share/${PORT})
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
