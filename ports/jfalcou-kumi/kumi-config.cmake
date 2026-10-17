# KUMI installs headers and nothing else. The target is written here rather than taken from the
# project's own install so the port needs no CMake configure, and no build-time dependency.
if(TARGET kumi::kumi)
  return()
endif()

get_filename_component(_kumi_prefix "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)

add_library(kumi::kumi INTERFACE IMPORTED)
set_target_properties(kumi::kumi PROPERTIES
  INTERFACE_COMPILE_FEATURES "cxx_std_20"
  INTERFACE_INCLUDE_DIRECTORIES "${_kumi_prefix}/include"
)

unset(_kumi_prefix)
