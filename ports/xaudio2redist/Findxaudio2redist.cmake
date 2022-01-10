include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)

set(XAUDIO2REDIST_VERSION "1.2.8")

if(NOT xaudio2redist_INCLUDE_DIR)
   find_path(xaudio2redist_INCLUDE_DIR
      NAMES xaudio2redist.h
      PATH_SUFFIXES xaudio2redist)
endif()

find_package_handle_standard_args(xaudio2redist
   REQUIRED_VARS xaudio2redist_INCLUDE_DIR
   VERSION_VAR XAUDIO2REDIST_VERSION)
mark_as_advanced(xaudio2redist_INCLUDE_DIR)

string(REPLACE "/include/xaudio2redist" "/lib" xaudio2redist_LIB_DIR ${xaudio2redist_INCLUDE_DIR})
string(REPLACE "/include/xaudio2redist" "/bin" xaudio2redist_BIN_DIR ${xaudio2redist_INCLUDE_DIR})
string(REPLACE "/include/xaudio2redist" "/debug/lib" xaudio2redist_DEBUG_LIB_DIR ${xaudio2redist_INCLUDE_DIR})
string(REPLACE "/include/xaudio2redist" "/debug/bin" xaudio2redist_DEBUG_BIN_DIR ${xaudio2redist_INCLUDE_DIR})

if(XAUDIO2REDIST_FOUND AND NOT TARGET Microsoft::XAudio2Redist)
   set(XAUDIO2_RELEASE_LIB "${xaudio2redist_LIB_DIR}/xaudio2_9redist.lib")
   set(XAUDIO2_RELEASE_DLL "${xaudio2redist_BIN_DIR}/xaudio2_9redist.dll")

   set(XAUDIO2_DEBUG_LIB "${xaudio2redist_DEBUG_LIB_DIR}/xaudio2_9redist.lib")
   set(XAUDIO2_DEBUG_DLL "${xaudio2redist_DEBUG_BIN_DIR}/xaudio2_9redist.dll")

   add_library(Microsoft::XAudio2Redist SHARED IMPORTED)
   set_target_properties(Microsoft::XAudio2Redist PROPERTIES
      IMPORTED_LOCATION_RELEASE            "${XAUDIO2_RELEASE_DLL}"
      IMPORTED_IMPLIB_RELEASE              "${XAUDIO2_RELEASE_LIB}"
      IMPORTED_LOCATION_DEBUG              "${XAUDIO2_DEBUG_DLL}"
      IMPORTED_IMPLIB_DEBUG                "${XAUDIO2_DEBUG_LIB}"
      INTERFACE_INCLUDE_DIRECTORIES        "${xaudio2redist_INCLUDE_DIR}"
      IMPORTED_CONFIGURATIONS              "Debug;Release"
      IMPORTED_LINK_INTERFACE_LANGUAGES    "C")
endif()

if(XAUDIO2REDIST_FOUND AND NOT TARGET Microsoft::XApoBase)
   set(XAPOBASE_RELEASE_LIB "${xaudio2redist_LIB_DIR}/xapobaseredist_md.lib")
   set(XAPOBASE_DEBUG_LIB "${xaudio2redist_DEBUG_LIB_DIR}/xapobaseredist_md.lib")

   if(NOT EXISTS ${XAPOBASE_RELEASE_LIB})
      set(XAPOBASE_RELEASE_LIB "${xaudio2redist_LIB_DIR}/xapobaseredist.lib")
      set(XAPOBASE_DEBUG_LIB "${xaudio2redist_DEBUG_LIB_DIR}/xapobaseredist.lib")
   endif()

   add_library(Microsoft::XApoBase STATIC IMPORTED)
   set_target_properties(Microsoft::XApoBase PROPERTIES
      IMPORTED_LOCATION_RELEASE            "${XAPOBASE_RELEASE_LIB}"
      IMPORTED_LOCATION_DEBUG              "${XAPOBASE_DEBUG_LIB}"
      INTERFACE_INCLUDE_DIRECTORIES        "${xaudio2redist_INCLUDE_DIR}"
      IMPORTED_CONFIGURATIONS              "Debug;Release")
endif()
