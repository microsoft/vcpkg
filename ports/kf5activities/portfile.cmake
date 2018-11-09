include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kactivities
    REF v5.51.0
    SHA512 1bcfaa0329568cb3cdb99686cb9fe568cdbde128023d83275e51dd52158f989861dae0b2835c506e1d443d34a3eff5a7f245d9d00a6ae42bb043b0021fef6fdf
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
            -DKDE_INSTALL_QMLDIR=qml
            -DKDE_INSTALL_DATAROOTDIR=data
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Activities)
vcpkg_copy_pdbs()

file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/kactivities-cli.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kactivities-cli.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/kf5activities RENAME copyright)
