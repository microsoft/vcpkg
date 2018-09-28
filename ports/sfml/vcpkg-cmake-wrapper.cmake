_find_package(${ARGS})

find_package(OpenAL CONFIG REQUIRED)
find_package(unofficial-vorbis CONFIG REQUIRED)

if(TARGET sfml-window)
    find_package(OpenGL QUIET COMPONENTS GLX)

    if(TARGET OpenGL::GLX)
        set_property(TARGET sfml-window APPEND PROPERTY INTERFACE_LINK_LIBRARIES "OpenGL::GLX")
    endif()
endif()
if(TARGET sfml-graphics)
    find_package(Freetype REQUIRED)
    set_property(TARGET sfml-graphics APPEND PROPERTY INTERFACE_LINK_LIBRARIES "Freetype::Freetype")
endif()
