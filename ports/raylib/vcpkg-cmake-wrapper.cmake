set(raylib_USE_STATIC_LIBS @STATIC@)

_find_package(${ARGS})

if(raylib_FOUND)
    get_filename_component(_raylib_lib_name ${raylib_LIBRARY} NAME)

    set(raylib_LIBRARY
        debug ${CURRENT_INSTALLED_DIR}/debug/lib/${_raylib_lib_name}
        optimized ${CURRENT_INSTALLED_DIR}/lib/${_raylib_lib_name}
    )

    set(raylib_LIBRARIES ${raylib_LIBRARY})
endif()
