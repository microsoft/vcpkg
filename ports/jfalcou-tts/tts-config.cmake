# TTS installs headers and nothing else. The target is written here rather than taken from the
# project's own install so the port needs no CMake configure, and no build-time dependency.
if(TARGET tts::tts)
  return()
endif()

get_filename_component(_tts_prefix "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)

add_library(tts::tts INTERFACE IMPORTED)
set_target_properties(tts::tts PROPERTIES
  INTERFACE_COMPILE_FEATURES "cxx_std_20"
  INTERFACE_INCLUDE_DIRECTORIES "${_tts_prefix}/include"
)

unset(_tts_prefix)
