vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Smithsonian/SuperNOVAS
    REF "v${VERSION}"
    SHA512 e1557fbe8e4550fc4c669e4cb7219069bce874942b47ae48edd769badcd548b6f9210f9243766ba3ae41b9cd3a3f33673e90c687d916a8934491ad3d380e9dad
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        solsys-calceph   ENABLE_CALCEPH
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF 
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
