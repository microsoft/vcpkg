find_path(AFXRES_H
  NAMES afxres.h
  PATHS $ENV{INCLUDE}
)

if(NOT AFXRES_H)
  message(FATAL_ERROR "Unable to locate 'afxres.h'. Ensure you have installed the ATL/MFC component of Visual Studio.")
endif()

SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)
