include(vcpkg_common_functions)

if (NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "qt5-activeqt only support Windows.")
endif()

include(${CURRENT_INSTALLED_DIR}/share/qt5modularscripts/qt_modular_library.cmake)

qt_modular_library(qtactiveqt 477c42653a59739aeeb17ab54bdd5cc50bc72a117250926e940c34d3f81d1b92356074056fb49f3cd811a88840377836b2d97cea8cbc62ae1d895168e7860753)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/qt5-activeqt/plugins/platforminputcontexts)
