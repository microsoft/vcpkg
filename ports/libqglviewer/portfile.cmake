vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GillesDebunne/libQGLViewer
    REF fee0916f2af3d0993df51956d2e5a51bbaf0c1f0 #v2.7.2
    SHA512 449bf4ccadaf50d4333bd91050e9b50f440a64229391827aaf4a80ade2c3f5fc60501d2baee885cf1214f7e2a8a04615bafe9ac7da9f866ffa4ebe33b9b999d8
    HEAD_REF master
    PATCHES
        use-default-config-on-all-platforms.patch
        destdir.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(OPTIONS CONFIG*=staticlib)
endif()

vcpkg_configure_qmake(
    SOURCE_PATH ${SOURCE_PATH}/QGLViewer/QGLViewer.pro
    OPTIONS ${OPTIONS}
)

vcpkg_install_qmake()

file(INSTALL ${SOURCE_PATH}/QGLViewer DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.h")
file(INSTALL ${SOURCE_PATH}/LICENCE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libqglviewer RENAME copyright)
