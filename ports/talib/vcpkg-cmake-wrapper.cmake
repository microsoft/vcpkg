get_filename_component(_prefix "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)

# Header lives at: <prefix>/include/ta_libc.h (Windows) or <prefix>/include/ta-lib/ta_libc.h (Unix)
find_path(talib_INCLUDE_DIR
  NAMES ta_libc.h ta-lib/ta_libc.h
  PATHS "${_prefix}/include"
  NO_DEFAULT_PATH
)

# Unix-style single lib
find_library(talib_LIBRARY_RELEASE
  NAMES ta-lib
  PATHS "${_prefix}/lib"
  NO_DEFAULT_PATH
)
find_library(talib_LIBRARY_DEBUG
  NAMES ta-lib
  PATHS "${_prefix}/debug/lib"
  NO_DEFAULT_PATH
)

set(talib_LIBRARIES_RELEASE "")
set(talib_LIBRARIES_DEBUG "")

if(talib_LIBRARY_RELEASE OR talib_LIBRARY_DEBUG)
  if(talib_LIBRARY_RELEASE)
    list(APPEND talib_LIBRARIES_RELEASE "${talib_LIBRARY_RELEASE}")
  endif()
  if(talib_LIBRARY_DEBUG)
    list(APPEND talib_LIBRARIES_DEBUG "${talib_LIBRARY_DEBUG}")
  endif()
else()
  foreach(component ta_common ta_func ta_abstract ta_libc)
    find_library(talib_${component}_LIBRARY_RELEASE
      NAMES ${component}
      PATHS "${_prefix}/lib"
      NO_DEFAULT_PATH
    )
    find_library(talib_${component}_LIBRARY_DEBUG
      NAMES ${component}
      PATHS "${_prefix}/debug/lib"
      NO_DEFAULT_PATH
    )

    if(talib_${component}_LIBRARY_RELEASE)
      list(APPEND talib_LIBRARIES_RELEASE "${talib_${component}_LIBRARY_RELEASE}")
    endif()
    if(talib_${component}_LIBRARY_DEBUG)
      list(APPEND talib_LIBRARIES_DEBUG "${talib_${component}_LIBRARY_DEBUG}")
    endif()
  endforeach()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(talib
  REQUIRED_VARS talib_INCLUDE_DIR talib_LIBRARIES_RELEASE
)

if(talib_FOUND AND NOT TARGET talib::talib)
  add_library(talib::talib INTERFACE IMPORTED)
  set_property(TARGET talib::talib PROPERTY
    INTERFACE_INCLUDE_DIRECTORIES "${talib_INCLUDE_DIR}"
  )

  if(NOT talib_LIBRARIES_DEBUG)
    set(talib_LIBRARIES_DEBUG "${talib_LIBRARIES_RELEASE}")
  endif()

  target_link_libraries(talib::talib INTERFACE
    $<$<CONFIG:Debug>:${talib_LIBRARIES_DEBUG}>
    $<$<CONFIG:RelWithDebInfo>:${talib_LIBRARIES_RELEASE}>
    $<$<CONFIG:Release>:${talib_LIBRARIES_RELEASE}>
    $<$<CONFIG:MinSizeRel>:${talib_LIBRARIES_RELEASE}>
  )
endif()
