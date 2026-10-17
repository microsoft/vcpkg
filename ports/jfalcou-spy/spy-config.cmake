# SPY installs headers and nothing else. The target is written here rather than taken from the
# project's own install so the port needs no CMake configure, and no build-time dependency.
if(TARGET spy::spy)
  return()
endif()

get_filename_component(_spy_prefix "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)

add_library(spy::spy INTERFACE IMPORTED)
set_target_properties(spy::spy PROPERTIES
  INTERFACE_COMPILE_FEATURES "cxx_std_20"
  INTERFACE_INCLUDE_DIRECTORIES "${_spy_prefix}/include"
)

set(SPY_LIBRARIES spy::spy)
unset(_spy_prefix)
