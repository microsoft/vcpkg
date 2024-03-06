cmake_path(SET GRDKLatest "$ENV{GRDKLatest}")

find_path(GRDK_H
  NAMES grdk.h
  PATHS "${GRDKLatest}/gameKit/Include"
)

cmake_path(SET GXDKLatest "$ENV{GXDKLatest}")

find_path(GXDK_H
  NAMES gxdk.h
  PATHS "${GXDKLatest}/gameKit/Include"
)

if(NOT (GRDK_H AND GXDK_H))
  message(FATAL_ERROR "Ensure you have installed the Microsoft GDK with Xbox Extensions installed. See https://aka.ms/gdkx.")
endif()

# Output user-friendly status message for installed edition.
if(${GXDKLatest} MATCHES ".*/([0-9][0-9])([0-9][0-9])([0-9][0-9])/.*")
  set(_months "null" "January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")
  list(GET _months ${CMAKE_MATCH_2} month)
  set(update "")
  if(${CMAKE_MATCH_3} GREATER 0)
    set(update " Update ${CMAKE_MATCH_3}")
  endif()
  message(STATUS "Found the Microsoft GDK with Xbox Extensions (${month} 20${CMAKE_MATCH_1}${update})")
endif()

SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)