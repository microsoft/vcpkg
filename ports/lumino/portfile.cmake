vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LuminoEngine/Lumino
    REF v0.10.1
    SHA512 a5de24024ec907180ff53d98a0a617a5fa9c96d440c82effd476b913f455ee1f36a4899e951e19ab20df73f9f5b9d60c321d883657ae0fb395e008c19c2ea51a
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

