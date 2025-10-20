get_filename_component(_gameinput_root "${CMAKE_CURRENT_LIST_DIR}" PATH)
get_filename_component(_gameinput_root "${_gameinput_root}" PATH)

set(_gameinput_root_lib "${_gameinput_root}/lib/gameinput.lib")

add_library(Microsoft::GameInput INTERFACE IMPORTED)
set_target_properties(Microsoft::GameInput PROPERTIES
   INTERFACE_LINK_LIBRARIES      "${_gameinput_root_lib}"
   INTERFACE_INCLUDE_DIRECTORIES "${_gameinput_root}/include")

unset(_gameinput_root_lib)
unset(_gameinput_root)
