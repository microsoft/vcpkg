vcpkg_list(SET OPTIONS)
if(NOT "quick" IN_LIST FEATURES)
    vcpkg_list(APPEND OPTIONS "QT.gui.name=" "QT.widgets.name=")
endif()

include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
qt_submodule_installation(
    OUT_SOURCE_PATH SOURCE_PATH
    OPTIONS
        ${OPTIONS}
)

if(NOT QT_UPDATE_VERSION)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/qt5/QtQml/${QT_MAJOR_MINOR_VER}.${QT_PATCH_VER}/QtQml/private/qqmljsparser_p.h" "${SOURCE_PATH}" "")
endif()
