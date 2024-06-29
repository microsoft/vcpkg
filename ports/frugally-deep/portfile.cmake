vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dobiasd/frugally-deep
    REF "v${VERSION}"
    SHA512 9695e61f5c0774d34a77153750a42597c0b63b7da1db8aaf421f540a1db584fd1962bc059bf93e13a28140f4cdfc0b64681ac6294e2269d853e3f07ccea7b506
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        double FDEEP_USE_DOUBLE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DFDEEP_BUILD_UNITTEST=OFF
    -DFDEEP_USE_TOOLCHAIN=ON
    ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/frugally-deep)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
