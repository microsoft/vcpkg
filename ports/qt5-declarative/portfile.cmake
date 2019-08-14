set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER ON)
include(
  ${CURRENT_INSTALLED_DIR}/share/qt5modularscripts/qt_modular_library.cmake)

qt_modular_library(
  qtdeclarative
  953b0dac76b73a7a21b393ab88718da12d77dfc688dc07c55c96ea1658bc14acd9097bef60df4a95d2923d3fb1e02b46499c032aa53844d4fd344b0037514671
  )

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/qt5-declarative/plugins/platforminputcontexts)
