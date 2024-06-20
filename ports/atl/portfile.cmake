find_path(ATLBASE_H
  NAMES atlbase.h
  PATHS $ENV{INCLUDE}
)

if(NOT ATLBASE_H)
  message(FATAL_ERROR "Unable to locate 'atlbase.h'. Ensure you have installed the Active Template Library (ATL) component of Visual Studio.")
endif()

SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)
