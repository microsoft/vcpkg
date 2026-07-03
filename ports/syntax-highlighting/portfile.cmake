vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/syntax-highlighting
    REF "v${VERSION}"
    SHA512 76a5b69ebb2538bcf3cfc11fcea5fe434f6f000d2bec939fbaa298913554fae0b0ea9e613e08f976cfd1950953ed60fb4236f04c0198c16bbd035ed7293eaa57
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
