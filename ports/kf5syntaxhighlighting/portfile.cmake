include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/syntax-highlighting
    REF v5.64.0
    SHA512 b33a136fad0e55054660c34328a208a19834c1adc9cdb9e8f334e9224492f2894bbcb355e61c8f6da6301363a11f832fa7e38cff293be249876048dd34c39476
    HEAD_REF master
)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path("${PERL_EXE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5SyntaxHighlighting)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/kf5syntaxhighlighting RENAME copyright)

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kate-syntax-highlighter.exe)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/kf5syntaxhighlighting)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/kate-syntax-highlighter.exe
            ${CURRENT_PACKAGES_DIR}/tools/kf5syntaxhighlighting/kate-syntax-highlighter.exe)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/kf5syntaxhighlighting)
