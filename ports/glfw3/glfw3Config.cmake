if (NOT TARGET glfw)
    add_library(glfw INTERFACE IMPORTED)
    set_target_properties(glfw PROPERTIES
        INTERFACE_LINK_OPTIONS "-sUSE_GLFW=3"
    )
endif()
