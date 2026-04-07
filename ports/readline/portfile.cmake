if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "No implementation of readline is currently available for UWP targets")
endif()

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
FILE(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
