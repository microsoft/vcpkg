vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/syntax-highlighting
    REF "v${VERSION}"
    SHA512 d45ef5f3974e324c087862fb9f5f084944e2d6df13f3df897514b6ed52ae69e59a0c309e0ae8361125c0c7ad2fe5c010296c174fddca1e7d5b0300a6b91dd438
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        translations KF_SKIP_PO_PROCESSING
)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path("${PERL_EXE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_codeeditor=OFF
        -DBUILD_codepdfprinter=OFF
        -DBUILD_minimaltest=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Python=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Quick=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_XercesC=ON
        -DKDE_INSTALL_QMLDIR=qml
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6syntaxhighlighting CONFIG_PATH lib/cmake/KF6SyntaxHighlighting)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES ksyntaxhighlighter6
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
