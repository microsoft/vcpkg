find_path(GRDK_H
  NAMES grdk.h
  PATHS "$ENV{GRDKLatest}/gameKit/Include"
)

find_path(GXDK_H
  NAMES gxdk.h
  PATHS "$ENV{GXDKLatest}/gameKit/Include"
)

if(NOT (GRDK_H AND GXDK_H))
  message(FATAL_ERROR "Ensure you have installed the Microsoft GDK with Xbox Extensions installed. See https://aka.ms/gdkx.")
endif()

SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)