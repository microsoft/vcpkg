include(CMakeFindDependencyMacro)

if(NOT TARGET goldy::goldy)
    add_library(goldy::goldy INTERFACE IMPORTED)
    
    get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)
    
    set_target_properties(goldy::goldy PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
    )
    
    if(WIN32)
        set_target_properties(goldy::goldy PROPERTIES
            INTERFACE_LINK_LIBRARIES "${_IMPORT_PREFIX}/lib/goldy_ffi.lib"
        )
    else()
        find_library(_GOLDY_FFI_LIB goldy_ffi PATHS "${_IMPORT_PREFIX}/lib" NO_DEFAULT_PATH)
        set_target_properties(goldy::goldy PROPERTIES
            INTERFACE_LINK_LIBRARIES "${_GOLDY_FFI_LIB}"
        )
    endif()
endif()
