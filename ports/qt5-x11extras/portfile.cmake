include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
qt_submodule_installation(BUILD_OPTIONS -verbose)
file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/config.log" DESTINATION "${CURRENT_BUILDTREES_DIR}/config-dbg.log")
file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/config.log" DESTINATION "${CURRENT_BUILDTREES_DIR}/config-rel.log")