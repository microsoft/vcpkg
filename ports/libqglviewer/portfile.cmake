include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GillesDebunne/libQGLViewer
    REF 28a23f14997dc2e08990b884c07075b48979cac7
    SHA512 58058543e07857f8b1480301b72f789290eee2d65382bee29773bcc1e3f45cedcee33b762bdb870b6cae8a0daab38ebdecde40e2f02720cf0f6fcf10f2007f25
    HEAD_REF master
    PATCHES "use-default-config-on-all-platforms.patch"
)

vcpkg_configure_qmake(SOURCE_PATH ${SOURCE_PATH}/QGLViewer/QGLViewer.pro)

vcpkg_build_qmake()

file(INSTALL ${SOURCE_PATH}/QGLViewer DESTINATION ${CURRENT_PACKAGES_DIR}/include  FILES_MATCHING  PATTERN "*.h")
if(CMAKE_HOST_WIN32)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(INSTALL ${SOURCE_PATH}/QGLViewer/QGLViewer2.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        file(INSTALL ${SOURCE_PATH}/QGLViewer/QGLViewerd2.dll ${SOURCE_PATH}/QGLViewer/QGLViewerd2.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(INSTALL ${SOURCE_PATH}/QGLViewer/QGLViewer2.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
        file(INSTALL ${SOURCE_PATH}/QGLViewer/QGLViewerd2.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    else()
        file(INSTALL ${SOURCE_PATH}/QGLViewer/QGLViewer.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
        file(INSTALL ${SOURCE_PATH}/QGLViewer/QGLViewerd.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    endif()
elseif(CMAKE_HOST_APPLE)
    file(INSTALL ${SOURCE_PATH}/QGLViewer/libQGLViewer.a  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL ${SOURCE_PATH}/QGLViewer/libQGLViewer.a DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

file(INSTALL ${SOURCE_PATH}/LICENCE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libqglviewer RENAME copyright)
