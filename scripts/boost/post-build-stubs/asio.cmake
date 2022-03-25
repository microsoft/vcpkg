
if("ssl" IN_LIST FEATURES)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/usage.ssl ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage COPYONLY)
else()
    configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage COPYONLY)
endif()
