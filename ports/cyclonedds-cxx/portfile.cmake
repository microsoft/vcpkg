vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse-cyclonedds/cyclonedds-cxx
    REF "${VERSION}"
    SHA512 62e1467030386f990562944cbf1a41b1a43b3d67dddc7828894b2823f7e35f68cdc0ecc967f0957d5fbbbe5eef666f3363a2d4d6b96177f8ab2504874c42e23f
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "idllib"                    BUILD_IDLLIB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/CycloneDDS-CXX")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
