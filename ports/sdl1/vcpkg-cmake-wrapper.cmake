_find_package(${ARGS})
if(SDL_LIBRARY)
    LIST(APPEND SDL_LIBRARY winmm.lib)
endif()