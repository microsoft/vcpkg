vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/syntax-highlighting
    REF "v${VERSION}"
    SHA512 a1ff5ae92624000baee9eea8e5d48040a967fd085482e6648c913d343a1d9d67b142c0867ad308100f0b7645237de15e78889b480d76ca25fad44b228aa0d957
    HEAD_REF master
    PATCHES
        001_fix_lnk2005_windows_static.patch
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
        -DKDE_INSTALL_QMLDIR=qml
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF6SyntaxHighlighting)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES ksyntaxhighlighter6
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
