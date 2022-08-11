_find_package(${ARGS})
if(GLUT_FOUND AND UNIX AND NOT ANDROID)
    cmake_policy(PUSH)
    cmake_policy(SET CMP0012 NEW)
    cmake_policy(SET CMP0054 NEW)
    cmake_policy(SET CMP0057 NEW)

    if(GLUT_LINK_LIBRARIES)
        # Since CMake 3.22, FindGLUT.cmake loads the glut pkg-config module.
        # We need `-lglut` resolved to an absolute path.
        set(GLUT_LIBRARIES "${GLUT_LINK_LIBRARIES}")
    else()
        find_package(X11)
        # Before CMake 3.14, FindX11.cmake doesn't create imported targets.
        # For X11, we simply assume shared linkage of system libs,
        # so order and transitive usage requirements don't matter.
        if(X11_Xrandr_FOUND AND NOT "Xrandr" IN_LIST GLUT_LIBRARIES)
            list(APPEND GLUT_LIBRARIES "${X11_Xrandr_LIB}")
            set_property(TARGET GLUT::GLUT APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${X11_Xrandr_LIB}")
        endif()
        # X11_xf86vmode_FOUND for CMake < 3.14
        if((X11_xf86vm_FOUND OR X11_xf86vmode_FOUND) AND NOT "Xxf86vm" IN_LIST GLUT_LIBRARIES)
            list(APPEND GLUT_LIBRARIES "${X11_Xxf86vm_LIB}")
            set_property(TARGET GLUT::GLUT APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${X11_Xxf86vm_LIB}")
        endif()
        if(X11_Xi_FOUND AND NOT GLUT_Xi_LIBRARY AND NOT "Xi" IN_LIST GLUT_LIBRARIES)
            list(APPEND GLUT_LIBRARIES "${X11_Xi_LIB}")
            set_property(TARGET GLUT::GLUT APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${X11_Xi_LIB}")
        endif()
    endif()

    cmake_policy(POP)
endif()
