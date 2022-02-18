include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
qt_submodule_installation(OUT_SOURCE_PATH SOURCE_PATH PATCHES limits_include.patch)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/qt5/QtQml/5.15.2/QtQml/private/qqmljsparser_p.h" "${SOURCE_PATH}" "")