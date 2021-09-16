vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/alkimia
    REF 595186bee8409f30e5db091fffa245fc53ad92e8
    SHA512 509082e22bc0a2ce0586e1167df14fd42ac85321315c1ee2914f60e695d1e2e8beae4fc93d16d0053edb520fc391a3dbe30777638285b295e761ad70512688ca
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DBUILD_DOXYGEN_DOCS=OFF
        -DBUILD_WITH_WEBKIT=OFF
        -DBUILD_WITH_WEBENGINE=OFF
        -DBUILD_APPLETS=OFF
        -DBUILD_TOOLS=OFF
        -DKDE_INSTALL_QMLDIR=qml
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME LibAlkimia5 CONFIG_PATH lib/cmake/LibAlkimia5-8.1)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
