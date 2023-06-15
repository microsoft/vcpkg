if(NOT TARGET unofficial::pdcurses::pdcurses)
    add_library(unofficial::pdcurses::pdcurses UNKNOWN IMPORTED)
    get_filename_component(z_vcpkg_pdcurses_root "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(z_vcpkg_pdcurses_root "${z_vcpkg_pdcurses_root}" PATH)
    get_filename_component(z_vcpkg_pdcurses_root "${z_vcpkg_pdcurses_root}" PATH)
    
    set_target_properties(unofficial::pdcurses::pdcurses PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${z_vcpkg_pdcurses_root}/include"
    )
    
    find_library(Z_VCPKG_PDCURSES_LIBRARY_RELEASE NAMES pdcurses PATHS "${z_vcpkg_pdcurses_root}/lib" NO_DEFAULT_PATH)
    find_file(Z_VCPKG_PDCURSES_DLL_RELEASE NAMES pdcurses.dll PATHS "${z_vcpkg_pdcurses_root}/bin" NO_DEFAULT_PATH)
    if(EXISTS "${Z_VCPKG_PDCURSES_LIBRARY_RELEASE}")
        set_property(TARGET unofficial::pdcurses::pdcurses APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        set_target_properties(unofficial::pdcurses::pdcurses PROPERTIES IMPORTED_IMPLIB_RELEASE "${Z_VCPKG_PDCURSES_LIBRARY_RELEASE}")
    endif()
    if(EXISTS "${Z_VCPKG_PDCURSES_DLL_RELEASE}")
        set_target_properties(unofficial::pdcurses::pdcurses PROPERTIES IMPORTED_LOCATION_RELEASE "${Z_VCPKG_PDCURSES_DLL_RELEASE}")
    endif()

    find_library(Z_VCPKG_PDCURSES_LIBRARY_DEBUG NAMES pdcurses PATHS "${z_vcpkg_pdcurses_root}/debug/lib" NO_DEFAULT_PATH)
    find_file(Z_VCPKG_PDCURSES_DLL_DEBUG NAMES pdcurses.dll PATHS "${z_vcpkg_pdcurses_root}/debug/bin" NO_DEFAULT_PATH)
    if(EXISTS "${Z_VCPKG_PDCURSES_LIBRARY_DEBUG}")
        set_property(TARGET unofficial::pdcurses::pdcurses APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(unofficial::pdcurses::pdcurses PROPERTIES IMPORTED_IMPLIB_DEBUG "${Z_VCPKG_PDCURSES_LIBRARY_DEBUG}")
    endif()
    if(EXISTS "${Z_VCPKG_PDCURSES_DLL_DEBUG}")
        set_target_properties(unofficial::pdcurses::pdcurses PROPERTIES IMPORTED_LOCATION_DEBUG "${Z_VCPKG_PDCURSES_DLL_DEBUG}")
    endif()
    
    unset(z_vcpkg_pdcurses_root)
endif()
