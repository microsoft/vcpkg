if (tinyxml_CONFIG_INCLUDED)
  return()
endif()
set(tinyxml_CONFIG_INCLUDED TRUE)

set(tinyxml_INCLUDE_DIRS "${CMAKE_CURRENT_LIST_DIR}/../../include")

foreach(lib tinyxml)
  set(onelib "${lib}-NOTFOUND")
  find_library(onelib ${lib}
      PATHS "${CMAKE_CURRENT_LIST_DIR}/../../lib"
    NO_DEFAULT_PATH
    )
  if(NOT onelib)
    message(FATAL_ERROR "Library '${lib}' in package tinyxml is not installed properly")
  endif()
  list(APPEND tinyxml_LIBRARIES ${onelib})
endforeach()

