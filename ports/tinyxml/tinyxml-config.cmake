if (tinyxml_CONFIG_INCLUDED)
  return()
endif()
set(tinyxml_CONFIG_INCLUDED TRUE)

include(${CMAKE_CURRENT_LIST_DIR}/tinyxmlTargets.cmake)
set(tinyxml_LIBRARIES tinyxml::tinyxml)
get_target_property(tinyxml_INCLUDE_DIRS tinyxml::tinyxml INTERFACE_INCLUDE_DIRECTORIES)