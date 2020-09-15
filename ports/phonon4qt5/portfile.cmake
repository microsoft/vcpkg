vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/phonon
    REF v4.11.1
    SHA512 f8c6c3d6265a3ca68aeb43d087dba596779d2d8bf9cf47d0f032dea1c5ca35e4b853b5dc166907437473ed1f8835a4b7cf6cf9deeea593e51ad9bfe80c6856c1
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_HTML_DOCS=OFF
        -DBUILD_MAN_DOCS=OFF
        -DBUILD_QTHELP_DOCS=OFF
        -DBUILD_TESTING=OFF
        -DPHONON_BUILD_DOC=OFF
        -DPHONON_BUILD_DEMOS=OFF
        -DPHONON_BUILD_SETTINGS=OFF
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        -DKDE_INSTALL_DATAROOTDIR=data
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Phonon4Qt5)

vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
