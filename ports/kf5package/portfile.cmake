include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kpackage
    REF v5.51.0
    SHA512 b467fae9c1f64ced7de5f87ca10007f25d5c94fd0ae93584cfa55f93eb6d65c6362cfb91b462e5bacde2457373bc19caea271df2493423df43e44b0e83a3b4b1
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
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Package)
vcpkg_copy_pdbs()

file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/kpackagetool5.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kpackagetool5.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/data/kservicetypes5)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data/kservicetypes5)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/kf5package RENAME copyright)
