vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/ktextwidgets
    REF "v${VERSION}"
    SHA512 fe3c55033d29c4dbf11e12e0ed108c16a28f32972dee8d20dce2a6d2e662b540683a05120dc642897fd749af4b92f6c641824b9396b58c2f644c94d21d9e2c4a
    HEAD_REF master
    PATCHES
        fix-static-dependencies.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        designerplugin BUILD_DESIGNERPLUGIN
        texttospeech   WITH_TEXT_TO_SPEECH
    INVERTED_FEATURES
        translations   KF_SKIP_PO_PROCESSING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DKDE_INSTALL_QTPLUGINDIR=Qt6/plugins
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6textwidgets CONFIG_PATH lib/cmake/KF6TextWidgets)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
