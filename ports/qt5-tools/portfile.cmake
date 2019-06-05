include(vcpkg_common_functions)

include(${CURRENT_INSTALLED_DIR}/share/qt5modularscripts/qt_modular_library.cmake)

file(COPY ${CURRENT_INSTALLED_DIR}/debug/lib/manual-link/Qt5Bootstrap.lib DESTINATION ${CURRENT_INSTALLED_DIR}/debug/lib)
file(COPY ${CURRENT_INSTALLED_DIR}/debug/lib/manual-link/Qt5Bootstrap.prl DESTINATION ${CURRENT_INSTALLED_DIR}/debug/lib)

qt_modular_library(qttools afce063e167de96dfa264cfd27dc8d80c23ef091a30f4f8119575cae83f39716c3b332427630b340f518b82d6396cca1893f28e00f3c667ba201d7e4fc2aefe1)

# End of hack: Remove these copies again
file(REMOVE ${CURRENT_INSTALLED_DIR}/debug/lib/Qt5Bootstrap.lib)
file(REMOVE ${CURRENT_INSTALLED_DIR}/debug/lib/Qt5Bootstrap.prl)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}//tools/qt5-tools/platforminputcontexts)
