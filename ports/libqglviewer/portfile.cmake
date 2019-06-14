include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GillesDebunne/libQGLViewer
    REF 781d914c003466b342b45d19266a9613fc0e7e0e
    SHA512 0586020c159fa4b3acb3ea3fa0a361bcc757d840298d7a436c356d0929b5ace3da4d054e3c0d107a499076413336e3b9a2f35750e6bf0add9320cc52a5c7afd5
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
