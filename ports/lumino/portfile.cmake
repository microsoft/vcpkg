vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LuminoEngine/Lumino
    REF main
    SHA512 efd7954674aea200f4b3001c783ae000e4dfd3ae3118f1ca69607a8622096286d75a8259eb1f8b0c990e1b29094530b7227f8fc2d876414402f8e9f080066af0
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES 
        engine  LUMINO_BUILD_ENGINE
)

vcpkg_cmake_configure(
    SOURCE_PATH
        "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLUMINO_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE)

