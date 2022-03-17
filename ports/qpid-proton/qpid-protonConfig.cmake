get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)
set(_IMPORT_PREFIX "${PACKAGE_PREFIX_DIR}")
include(${CMAKE_CURRENT_LIST_DIR}/Proton/ProtonConfig.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/ProtonCpp/ProtonCppConfig.cmake)
