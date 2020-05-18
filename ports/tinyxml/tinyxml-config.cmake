if (tinyxml_CONFIG_INCLUDED)
  return()
endif()
set(tinyxml_CONFIG_INCLUDED TRUE)

include(${CMAKE_CURRENT_LIST_DIR}/tinyxmlTargets.cmake)
set(tinyxml_LIBRARIES unofficial-tinyxml::unofficial-tinyxml)
get_target_property(tinyxml_INCLUDE_DIRS unofficial-tinyxml::unofficial-tinyxml INTERFACE_INCLUDE_DIRECTORIES)