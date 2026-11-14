vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kitemmodels
    REF "v${VERSION}"
    SHA512 addcb8a49fc1be6ad61418f3632fdaacd892165d684be1bcb624cf59dd64c0940414789d5487d1969a4730869144c056f076f70f893797f7eb9b5156f1e08a0d
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        qml CMAKE_REQUIRE_FIND_PACKAGE_Qt6Qml
    INVERTED_FEATURES
        qml CMAKE_DISABLE_FIND_PACKAGE_Qt6Qml
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DKDE_INSTALL_QMLDIR=Qt6/qml
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME kf6itemmodels
    CONFIG_PATH lib/cmake/KF6ItemModels
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
