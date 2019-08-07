include(vcpkg_common_functions)

include(
  ${CURRENT_INSTALLED_DIR}/share/qt5modularscripts/qt_modular_library.cmake)

qt_modular_library(
  qtdeclarative
  953b0dac76b73a7a21b393ab88718da12d77dfc688dc07c55c96ea1658bc14acd9097bef60df4a95d2923d3fb1e02b46499c032aa53844d4fd344b0037514671
  )

file(
  REMOVE_RECURSE
  ${CURRENT_PACKAGES_DIR}/tools/qt5-declarative/plugins/platforminputcontexts)

# if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
# set(qt5decpath ${CURRENT_PACKAGES_DIR}/share/qt5/debug/mkspecs/modules/qt_lib_
# qmldevtools_private.pri) file(READ "${qt5decpath}" _contents) string(REPLACE
# [[QT.qmldevtools_private.libs = $$QT_MODULE_HOST_LIB_BASE]]
# [[QT.qmldevtools_private.libs = $$QT_MODULE_LIB_BASE]]  _contents
# "${_contents}") file(WRITE "${qt5decpath}" "${_contents}") endif()
