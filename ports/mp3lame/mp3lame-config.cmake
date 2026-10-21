get_filename_component(_mp3lame_root "${CMAKE_CURRENT_LIST_DIR}" PATH)
get_filename_component(_mp3lame_root "${_mp3lame_root}" PATH)

if(NOT TARGET mp3lame::mp3lame)
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

    set(_mp3lame_mpghip_rel_lib "${_mp3lame_root}/lib/libmpghip-static.lib")
    set(_mp3lame_mpghip_dbg_lib "${_mp3lame_root}/debug/lib/libmpghip-static.lib")
    if(EXISTS "${_mp3lame_mpghip_rel_lib}")
        add_library(#[[skip-usage-heuristics]] mp3lame::mpghip UNKNOWN IMPORTED)
        set_target_properties(mp3lame::mpghip PROPERTIES
            IMPORTED_CONFIGURATIONS RELEASE
            IMPORTED_LOCATION_RELEASE "${_mp3lame_mpghip_rel_lib}"
        )
        if (EXISTS "${_mp3lame_dbg_lib}")
            set_target_properties(mp3lame::mpghip PROPERTIES IMPORTED_LOCATION_DEBUG "${_mp3lame_mpghip_dbg_lib}")
            set_property(TARGET mp3lame::mpghip APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        endif()
        set_target_properties(mp3lame::mp3lame PROPERTIES INTERFACE_LINK_LIBRARIES mp3lame::mpghip)
    endif()
    unset(_mp3lame_mpghip_rel_lib)
    unset(_mp3lame_mpghip_dbg_lib)
endif()

unset(_mp3lame_root)
