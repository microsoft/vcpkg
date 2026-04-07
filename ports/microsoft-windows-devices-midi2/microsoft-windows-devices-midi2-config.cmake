set(MIDI2_WINDOWS_SDK_VERSION "@WINDOWS_SDK_VERSION@")
set(MIDI2_SDK_VERSION "@MIDI_SDK_VERSION@")

get_filename_component(_MIDI2_ROOT "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
get_filename_component(_MIDI2_ROOT "${_MIDI2_ROOT}" DIRECTORY)

add_library(Microsoft::Windows::Devices::Midi2 INTERFACE IMPORTED)
set_target_properties(Microsoft::Windows::Devices::Midi2 PROPERTIES
  INTERFACE_COMPILE_FEATURES cxx_std_17
  INTERFACE_INCLUDE_DIRECTORIES "${_MIDI2_ROOT}/include"
)

unset(_MIDI2_ROOT)
