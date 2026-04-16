vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Smithsonian/SuperNOVAS
    REF "v${VERSION}"
    SHA512 672075f72a02634435f49328bd70b3f2ca95cc06b0e9d73a287610902b6e7e19fc4baff3717e3aa621903ebc5bd01df56a19bbd63828ece33967bdf46ce266ef
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cpp              ENABLE_CPP
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
