vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/knewstuff
    REF "v${VERSION}"
    SHA512 7734b5403720e4031d30844361251f744364d109c60dd59e6424cf1aa2f7a5b87f5f81893c0cab5721dc0875fc5e9b6e510436e4485776ec3f30d6d36ffca476
    HEAD_REF master
    PATCHES
        disable-macos-bundle.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        designer-plugin BUILD_DESIGNERPLUGIN
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=1
        -DCMAKE_DISABLE_FIND_PACKAGE_KF5Kirigami2=1
        -DCMAKE_DISABLE_FIND_PACKAGE_KF5Syndication=1
        -DCMAKE_REQUIRE_FIND_PACKAGE_Qt5Quick=1
        ${options}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5NewStuffCore  PACKAGE_NAME kf5newstuffcore  DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5NewStuffQuick PACKAGE_NAME kf5newstuffquick DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5NewStuff)

vcpkg_copy_tools(
    TOOL_NAMES knewstuff-dialog
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
