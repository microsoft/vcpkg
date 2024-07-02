set(TAOX11_FOUND FALSE)

find_path(
  TAOX11_INCLUDE_DIR tao/x11/corba.h
  PATHS $ENV{ACE_ROOT}
        $ENV{TAO_ROOT}/x11
        $ENV{TAO_ROOT}/x11
        /include
        $ENV{ACE_ROOT}/include
        /usr/include
        /usr/local/include
  NO_DEFAULT_PATH)
find_library(
  TAOX11_LIBRARY_RELEASE
  NAMES taox11
  PATHS $ENV{ACE_ROOT}/lib /usr/lib /usr/lib64 /usr/local/lib /usr/local/lib64
  NO_DEFAULT_PATH)
find_library(
  TAOX11_LIBRARY_DEBUG
  NAMES taox11d
  PATHS $ENV{ACE_ROOT}/lib /debug/lib /usr/lib /usr/lib64 /usr/local/lib
        /usr/local/lib64
  NO_DEFAULT_PATH)
find_program(
  RIDLC_COMPILER
  "ridlc"
  /usr/bin
  $ENV{TAO_ROOT}/bin
  $ENV{ACE_ROOT}/bin
  /usr/bin
  /usr/local/bin
  /tools/axcioma/bin
  NO_DEFAULT_PATH)
message(STATUS "ridlc at: ${RIDLC_COMPILER}")

if(TAOX11_INCLUDE_DIR AND TAOX11_LIBRARY_RELEASE) # AND TAOX11_IDL_COMPILER)
  set(TAOX11_FOUND TRUE)
endif(TAOX11_INCLUDE_DIR AND TAOX11_LIBRARY_RELEASE) # AND TAOX11_IDL_COMPILER)
# now let's search for parts of tao we need.

get_filename_component(TAOX11_LIBRARY_RELEASE_DIR ${TAOX11_LIBRARY_RELEASE}
                       PATH)
get_filename_component(TAOX11_LIBRARY_DEBUG_DIR ${TAOX11_LIBRARY_DEBUG} PATH)

set(TAOX11_LIBRARIES_RELEASE ${TAOX11_LIBRARY_RELEASE})
set(TAOX11_LIBRARIES_DEBUG ${TAOX11_LIBRARY_DEBUG})

if(TAOX11_FOUND)

  set(TAOX11_FIND_LIBS
      "anytypecode"
      "bidir_giop"
      "codecfactory"
      "cosnaming_skel"
      "cosnaming_stub"
      "dynamicany"
      "ifr_client_skel"
      "ifr_client_stub"
      "ior_interceptor"
      "ior_table"
      "messaging"
      "ort"
      "pi"
      "pi_server"
      "portable_server"
      "typecodefactory"
      "valuetype"
      "x11_logger")

  message("Finding TAOX11 libraries...")

  if(WIN32)
    message(STATUS "taox11 release found at: ${TAOX11_LIBRARY_RELEASE}")
    message(STATUS "taox11 debug found at: ${TAOX11_LIBRARY_DEBUG}")
    set(TAOX11_LIBRARY optimized ${TAOX11_LIBRARY_RELEASE} debug
                       ${TAOX11_LIBRARY_DEBUG})
  else(WIN32)
    message(STATUS "TAOX11 found at: ${TAOX11_LIBRARY_RELEASE}")
    set(TAOX11_LIBRARY ${TAOX11_LIBRARY_RELEASE})
  endif(WIN32)

  foreach(LIBRARY ${TAOX11_FIND_LIBS})
    if(WIN32)
      find_library(
        TAOX11_${LIBRARY}_LIBRARY_DEBUG
        NAMES "taox11_${LIBRARY}d"
        PATHS ${TAOX11_LIBRARY_DEBUG_DIR}
        NO_DEFAULT_PATH)
      if(TAOX11_${LIBRARY}_LIBRARY_DEBUG)
        message(
          STATUS "${LIBRARY} debug found at: ${TAOX11_${LIBRARY}_LIBRARY_DEBUG}"
        )
        list(APPEND TAOX11_LIBRARIES_DEBUG ${TAOX11_${LIBRARY}_LIBRARY_DEBUG})
      else(TAOX11_${LIBRARY}_LIBRARY_DEBUG)
        set(TAOX11_FOUND FALSE)
      endif(TAOX11_${LIBRARY}_LIBRARY_DEBUG)
    endif(WIN32)

    find_library(
      TAOX11_${LIBRARY}_LIBRARY_RELEASE
      NAMES "taox11_${LIBRARY}"
      PATHS ${TAOX11_LIBRARY_RELEASE_DIR}
      NO_DEFAULT_PATH)
    if(TAOX11_${LIBRARY}_LIBRARY_RELEASE)
      if(WIN32)
        message(
          STATUS
            "${LIBRARY} release found at: ${TAOX11_${LIBRARY}_LIBRARY_RELEASE}")
      else(WIN32)
        message(
          STATUS "${LIBRARY} found at: ${TAOX11_${LIBRARY}_LIBRARY_RELEASE}")
      endif(WIN32)
      list(APPEND TAOX11_LIBRARIES_RELEASE ${TAOX11_${LIBRARY}_LIBRARY_RELEASE})
    else(TAOX11_${LIBRARY}_LIBRARY_RELEASE)
      set(TAOX11_FOUND FALSE)
    endif(TAOX11_${LIBRARY}_LIBRARY_RELEASE)

    if(WIN32)
      set(TAOX11_${LIBRARY}_LIBRARY
          optimized ${TAOX11_${LIBRARY}_LIBRARY_RELEASE} debug
          ${TAOX11_${LIBRARY}_LIBRARY_DEBUG})
    else(WIN32)
      set(TAOX11_${LIBRARY}_LIBRARY ${TAOX11_${LIBRARY}_LIBRARY_RELEASE})
    endif(WIN32)
  endforeach()

  if(WIN32)
    find_library(
      TAOX11_logger_LIBRARY_DEBUG
      NAMES "x11_loggerd"
      PATHS ${TAOX11_LIBRARY_DEBUG_DIR}
      NO_DEFAULT_PATH)
    if(TAOX11_logger_LIBRARY_DEBUG)
      message(
        STATUS "x11_logger debug found at: ${TAOX11_logger_LIBRARY_DEBUG}")
      list(APPEND TAOX11_LIBRARIES_DEBUG ${TAOX11_logger_LIBRARY_DEBUG})
    else(TAOX11_logger_LIBRARY_DEBUG)
      set(TAOX11_FOUND FALSE)
    endif(TAOX11_logger_LIBRARY_DEBUG)
  endif(WIN32)

  find_library(
    TAOX11_logger_LIBRARY_RELEASE
    NAMES "x11_logger"
    PATHS ${TAOX11_LIBRARY_RELEASE_DIR}
    NO_DEFAULT_PATH)
  if(TAOX11_logger_LIBRARY_RELEASE)
    if(WIN32)
      message(
        STATUS "x11_logger release found at: ${TAOX11_logger_LIBRARY_RELEASE}")
    else(WIN32)
      message(STATUS "x11_logger found at: ${TAOX11_logger_LIBRARY_RELEASE}")
    endif(WIN32)
    list(APPEND TAOX11_LIBRARIES_RELEASE ${TAOX11_logger_LIBRARY_RELEASE})
  else(TAOX11_logger_LIBRARY_RELEASE)
    set(TAOX11_FOUND FALSE)
  endif(TAOX11_logger_LIBRARY_RELEASE)

  if(WIN32)
    set(TAOX11_logger_LIBRARY optimized ${TAOX11_logger_LIBRARY_RELEASE} debug
                              ${TAOX11_logger_LIBRARY_DEBUG})
  else(WIN32)
    set(TAOX11_logger_LIBRARY ${TAOX11_logger_LIBRARY_RELEASE})
  endif(WIN32)

endif(TAOX11_FOUND)
