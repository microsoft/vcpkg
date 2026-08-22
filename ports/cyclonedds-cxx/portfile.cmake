vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse-cyclonedds/cyclonedds-cxx
    REF "${VERSION}"
    SHA512 fd03beca1f2b7140c213a2be8c19390c308469b625e2bafd66935258d4e6bec6a8c01940c208501f2619c36f0a04f6538b17b1b7ca562ab5a7533be0747e5bef
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
