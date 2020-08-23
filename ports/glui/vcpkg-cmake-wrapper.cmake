_find_package(${ARGS})

if(TARGET glui::glui AND NOT TARGET glui::glui_static)
    add_library(glui::glui_static INTERFACE IMPORTED)
    set_target_properties(glui::glui_static PROPERTIES INTERFACE_LINK_LIBRARIES glui::glui)
elseif(TARGET glui::glui_static AND NOT TARGET glui::glui)
    add_library(glui::glui INTERFACE IMPORTED)
    set_target_properties(glui::glui PROPERTIES INTERFACE_LINK_LIBRARIES glui::glui_static)
endif()
