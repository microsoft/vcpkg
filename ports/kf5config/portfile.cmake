include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kconfig
    REF v5.51.0
    SHA512 80928ec9befb50523bf81da605f375f4c921052f9a1b5f3b5185c5c7a219665e86ac60828cb6eac3aa553c8134742284c408e45f4616dfbfd60f4a43fa31619f
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

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/kf5config)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/kconfig_compiler_kf5.exe ${CURRENT_PACKAGES_DIR}/tools/kf5config/kconfig_compiler_kf5.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/kconf_update.exe ${CURRENT_PACKAGES_DIR}/tools/kf5config/kconf_update.exe)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Config)

file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/kreadconfig5.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/kwriteconfig5.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kconfig_compiler_kf5.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kconf_update.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kreadconfig5.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kwriteconfig5.exe)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/kf5config)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/kf5config RENAME copyright)
