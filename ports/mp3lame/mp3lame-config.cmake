get_filename_component(_mp3lame_root "${CMAKE_CURRENT_LIST_DIR}" PATH)
get_filename_component(_mp3lame_root "${_mp3lame_root}" PATH)

if(NOT TARGET mp3lame::mp3lame)
    include(CMakeFindDependencyMacro)
    find_dependency(mpg123 CONFIG REQUIRED)

    set(_mp3lame_lib_names libmp3lame libmp3lame-static mp3lame)
    find_library(_mp3lame_rel_lib NAMES ${_mp3lame_lib_names} PATHS "${_mp3lame_root}/lib" NO_CACHE NO_DEFAULT_PATH)
    find_library(_mp3lame_dbg_lib NAMES ${_mp3lame_lib_names} PATHS "${_mp3lame_root}/debug/lib" NO_CACHE NO_DEFAULT_PATH)

    add_library(mp3lame::mp3lame UNKNOWN IMPORTED)
    set_target_properties(mp3lame::mp3lame PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_mp3lame_root}/include"
        IMPORTED_CONFIGURATIONS RELEASE
        IMPORTED_LOCATION_RELEASE "${_mp3lame_rel_lib}"
    )
    if(_mp3lame_lib_debug)
        set_target_properties(mp3lame::mp3lame PROPERTIES IMPORTED_LOCATION_DEBUG "${_mp3lame_dbg_lib}")
        set_property(TARGET mp3lame::mp3lame APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
    endif()
    unset(_mp3lame_rel_lib)
    unset(_mp3lame_dbg_lib)
    unset(_mp3lame_lib_names)

    set_target_properties(mp3lame::mp3lame PROPERTIES INTERFACE_LINK_LIBRARIES MPG123::libmpg123)
endif()

unset(_mp3lame_root)
