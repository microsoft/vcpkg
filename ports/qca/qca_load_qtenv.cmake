# TODO: Better way to find Qt5 dir
#

set(_QT5_FOUND FALSE)

# Already available?
find_package(Qt5Core QUIET)
if(Qt5Core_FOUND)
  message(STATUS "Qt5 found by CMake. Version: " ${Qt5Core_VERSION})
  set(_QT5_FOUND TRUE)
  return()

elseif(NOT Qt5Core_FOUND)
  # Try to find Qt in the Windows Registry (just msvc2015 and msvc2015_64 for now)
  if(${TRIPLET_SYSTEM_ARCH} STREQUAL "x86")
    set(_QTKEY "HKEY_CURRENT_USER\\SOFTWARE\\Digia\\Versions\\msvc2015")
  elseif(${TRIPLET_SYSTEM_ARCH} STREQUAL "x64")
    set(_QTKEY "HKEY_CURRENT_USER\\SOFTWARE\\Digia\\Versions\\msvc2015_64")
  endif()
  get_filename_component(_QTPATH "[${_QTKEY};InstallDir]" ABSOLUTE)
  if(NOT ${_QTPATH} STREQUAL "/registry") # Path should be ok
    message(STATUS "Qt found in the registry: ${_QTPATH}")
    set(QT5 ${_QTPATH})
    set(_QT5_FOUND TRUE)
  endif()
endif(Qt5Core_FOUND)

if((NOT _QT5_FOUND) AND (NOT DEFINED $ENV{QT5}))
  message(STATUS " ")
  message(STATUS "QT5 not found.")
  message(STATUS "Please set the path to the Qt5 ${TRIPLET_SYSTEM_ARCH} toolchain dir for this session with f. e.:") 
  message(STATUS "  \$env:QT5 = \"path\\to\\Qt\\msvc[_64]\"")
  message(FATAL_ERROR "")
elseif(_QT5_FOUND AND (${TARGET_TRIPLET} STREQUAL "x64-windows" OR ${TARGET_TRIPLET} STREQUAL "x86-windows"))
  #message(STATUS "Using Qt5: ${QT5}")
  #set(ENV{QTDIR} ${QT5})
  set(ENV{PATH} "${QT5}/bin;$ENV{PATH}")
else()
  message(FATAL_ERROR "Target triplet: ${TARGET_TRIPLET} not supported yet.")
endif()
