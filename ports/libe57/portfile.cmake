vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hlrs-vis/libe57
    REF "v${VERSION}"
    SHA512 2acea522f2ac8e86414a4839d57407c7ae5473d2532b73bf2bdd72e0bd0a138c89d770de067ae1ebf488b614ab53c99e7f2a67cea31eea64e94c1ae2c539321b	
    HEAD_REF main
    PATCHES
        boost_includes.patch
        e57simple.patch
        export_config.patch
        xercesc.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake PACKAGE_NAME e57refimpl)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES e57fields e57unpack e57validate e57xmldump las2e57
    AUTO_CLEAN
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

file(WRITE "${CURRENT_BUILDTREES_DIR}/copyright"
    "See the libE57 website for copyright and licensing information (http://libe57.org/license.html)."
)

vcpkg_install_copyright(FILE_LIST "${CURRENT_BUILDTREES_DIR}/copyright")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
