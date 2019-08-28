_find_package(GLEW CONFIG)
if(TARGET GLEW::glew AND NOT DEFINED GLEW_INCLUDE_DIRS)
    get_target_property(GLEW_INCLUDE_DIRS GLEW::glew INTERFACE_INCLUDE_DIRECTORIES)
    get_target_property(GLEW_LIBRARY_DEBUG GLEW::glew IMPORTED_IMPLIB_DEBUG)
    get_target_property(GLEW_LIBRARY_RELEASE GLEW::glew IMPORTED_IMPLIB_RELEASE)
    get_target_property(GLEW_LINK_INTERFACE GLEW::glew IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE) # same for debug and release
    select_library_configurations(GLEW)
    list(APPEND GLEW_LIBRARIES ${GLEW_LINK_INTERFACE})
endif()