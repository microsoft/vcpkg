if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "No implementation of readline is currently available for UWP targets")
endif()

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
