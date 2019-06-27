include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kdesignerplugin
    REF v5.51.0
    SHA512 5e25c3fe6147934712d00b28c7220b210cfeb5003806ce638a71b74f6fa5682505b8732ec1948b1e6643a651bbfc55cf6b55483236421dae4e5ec56f10fd45be
    HEAD_REF master
)

vcpkg_acquire_msys(MSYS_ROOT PACKAGES mingw-w64-i686-gettext)
set(GETTEXT_PATH ${MSYS_ROOT}/mingw32/bin)
vcpkg_add_to_path(${GETTEXT_PATH})
vcpkg_add_to_path(${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/debug/bin)
vcpkg_add_to_path(${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/bin)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
            -DKDE_INSTALL_PLUGINDIR=plugins
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5DesignerPlugin)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/kf5designerplugin RENAME copyright)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
