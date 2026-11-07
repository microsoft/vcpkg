vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/ktextwidgets
    REF "v${VERSION}"
    SHA512 97d43b1ec348d77293f3a6a62c07fa5bdc5955fd1a5f98373cbc63906df5112127eac4ca0107029823d5c824e41f7e4029f2638e329d124dde7eafdd05dd3844
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
