include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kglobalaccel
    REF v5.51.0
    SHA512 ade2687d25948040fbf9dfe1f3a73218085681159a0a10f3c2fa1f9a2dd93ac9b342b5fbc19b6630d3f8838308fcf44056783742096f8eb073c5b8c7b640ea57
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5GlobalAccel)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/kglobalaccel5.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/kglobalaccel5.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/data/kservices5)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data/kservices5)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/data/dbus-1/services)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data/dbus-1/services)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/kf5globalaccel RENAME copyright)
