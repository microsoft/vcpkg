include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kconfigwidgets
    REF v5.51.0
    SHA512 45a71dc21455d08ef2e4a6c8794f880b8a5992d6a5efc9bb2f9c95f502306837573c3368958cbffdded823e6b5f038d1cb668e160b655806f5176e770ec0fe1b
    HEAD_REF master
)

vcpkg_acquire_msys(MSYS_ROOT PACKAGES mingw-w64-i686-gettext)
set(GETTEXT_PATH ${MSYS_ROOT}/mingw32/bin)
vcpkg_add_to_path(${GETTEXT_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5ConfigWidgets)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/preparetips5)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/preparetips5)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/kf5configwidgets RENAME copyright)
