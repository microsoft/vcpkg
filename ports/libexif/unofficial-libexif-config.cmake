
if(NOT TARGET unofficial::libexif::libexif)
    add_library(unofficial::libexif::libexif UNKNOWN IMPORTED)
    get_filename_component(z_vcpkg_LIBEXIF_root "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(z_vcpkg_LIBEXIF_ROOT "${z_vcpkg_LIBEXIF_root}" PATH)
    get_filename_component(z_VCPKG_LIBEXIF_ROOT "${z_vcpkg_LIBEXIF_ROOT}" PATH)
    set_target_properties(unofficial::libexif::libexif PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${z_VCPKG_LIBEXIF_ROOT}/include"
    )
    find_library(Z_VCPKG_LIBEXIF_LIBRARY_RELEASE NAMES exif PATHS "${z_VCPKG_LIBEXIF_ROOT}/lib" NO_DEFAULT_PATH REQUIRED)
    find_library(Z_VCPKG_LIBEXIF_LIBRARY_DEBUG NAMES exif PATHS "${z_VCPKG_LIBEXIF_ROOT}/debug/lib" NO_DEFAULT_PATH)
    
    if(EXISTS "${Z_VCPKG_LIBEXIF_LIBRARY_RELEASE}")
        set_property(TARGET unofficial::libexif::libexif APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        set_target_properties(unofficial::libexif::libexif PROPERTIES
            IMPORTED_LOCATION_RELEASE  "${Z_VCPKG_LIBEXIF_LIBRARY_RELEASE}"
        )
    endif()
  
    if(EXISTS "${Z_VCPKG_LIBEXIF_LIBRARY_DEBUG}")
        set_property(TARGET unofficial::libexif::libexif APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(unofficial::libexif::libexif PROPERTIES
            IMPORTED_LOCATION_DEBUG "${Z_VCPKG_LIBEXIF_LIBRARY_DEBUG}"
        )
    endif()

    unset(z_vcpkg_LIBEXIF_root)
    unset(z_vcpkg_LIBEXIF_ROOT)
    unset(z_VCPKG_LIBEXIF_ROOT)
endif()
