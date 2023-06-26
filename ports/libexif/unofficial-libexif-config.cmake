
find_library(Z_VCPKG_LIBEXIF_LIBRARY_RELEASE NAMES libexif PATHS "${z_vcpkg_libexif_root}/lib" NO_DEFAULT_PATH)
find_library(Z_VCPKG_LIBEXIF_LIBRARY_DEBUG NAMES libexif PATHS "${z_vcpkg_libexif_root}/debug/lib" NO_DEFAULT_PATH)

if(NOT TARGET unofficial::libexif::libexif)
    add_library(unofficial::libexif::libexif UNKNOWN IMPORTED)
    get_filename_component(z_vcpkg_LIBEXIF_root "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(z_vcpkg_LIBEXIF_root "${z_vcpkg_libexif_root}" PATH)
    get_filename_component(z_vcpkg_LIBEXIF_root "${z_vcpkg_libexif_root}" PATH)

    set_target_properties(unofficial::libexif::libexif PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${z_vcpkg_libexif_root}/include"
    )
    
    if(EXISTS "${Z_VCPKG_LIBEXIF_LIBRARY_RELEASE}")
        set_property(TARGET unofficial::libexif::libexif APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        set_target_properties(unofficial::libexif::libexif PROPERTIES
            IMPORTED_IMPLIB_RELEASE "${Z_VCPKG_LIBEXIF_LIBRARY_RELEASE}"
        )
    endif()
  
    if(EXISTS "${Z_VCPKG_LIBEXIF_LIBRARY_DEBUG}")
        set_property(TARGET unofficial::libexif::libexif APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(unofficial::libexif::libexif PROPERTIES
            IMPORTED_IMPLIB_DEBUG "${Z_VCPKG_LIBEXIF_LIBRARY_DEBUG}"
        )
    endif()

    unset(z_vcpkg_LIBEXIF_root)
endif()
