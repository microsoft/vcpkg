if(NOT TARGET unofficial::pdcurses::pdcurses)
    add_library(unofficial::pdcurses::pdcurses UNKNOWN IMPORTED)
    get_filename_component(z_vcpkg_pdcurses_root "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(z_vcpkg_pdcurses_root "${z_vcpkg_pdcurses_root}" PATH)
    get_filename_component(z_vcpkg_pdcurses_root "${z_vcpkg_pdcurses_root}" PATH)
    
    find_library(Z_VCPKG_PDCURSES_LIBRARY_RELEASE NAMES pdcurses PATHS "${z_vcpkg_pdcurses_root}/lib" NO_DEFAULT_PATH REQUIRED)
    find_library(Z_VCPKG_PDCURSES_LIBRARY_DEBUG NAMES pdcurses PATHS "${z_vcpkg_pdcurses_root}/debug/lib" NO_DEFAULT_PATH REQUIRED)
    
    set_target_properties(unofficial::pdcurses::pdcurses PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${z_vcpkg_pdcurses_root}/include"
      IMPORTED_LOCATION_DEBUG "${Z_VCPKG_PDCURSES_LIBRARY_DEBUG}"
      IMPORTED_LOCATION_RELEASE "${Z_VCPKG_PDCURSES_LIBRARY_RELEASE}"
      IMPORTED_CONFIGURATIONS "Release;Debug"
    )
    
    unset(z_vcpkg_pdcurses_root)
endif()
