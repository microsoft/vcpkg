include("${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake")

if("d3d12" IN_LIST FEATURES)
    list(APPEND CORE_OPTIONS -d3d12)
else()
    list(APPEND CORE_OPTIONS -no-d3d12)
endif()

qt_submodule_installation(OUT_SOURCE_PATH SOURCE_PATH BUILD_OPTIONS ${CORE_OPTIONS})

if(NOT QT_UPDATE_VERSION)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/qt5/QtQml/${QT_MAJOR_MINOR_VER}.${QT_PATCH_VER}/QtQml/private/qqmljsparser_p.h" "${SOURCE_PATH}" "")
endif()
