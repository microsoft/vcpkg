if(NOT TARGET unofficial::skia::@name@)
    add_library(unofficial::skia::@name@ UNKNOWN IMPORTED)
    z_vcpkg_skia_get_link_libraries(
        z_vcpkg_skia_link_libs_release
        "${z_vcpkg_skia_root}/lib;${z_vcpkg_skia_root}/debug/lib"
        "@SKIA_DEP_REL@"
    )
    set_target_properties(unofficial::skia::@name@ PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${z_vcpkg_skia_root}/include/skia"
        IMPORTED_CONFIGURATIONS RELEASE
        IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
        IMPORTED_LOCATION_RELEASE "${z_vcpkg_skia_root}/lib/@SKIA_LIB_REL@"
        INTERFACE_COMPILE_DEFINITIONS "\$<\$<NOT:${z_vcpkg_skia_config_debug}>:@SKIA_DEFINITIONS_REL@>"
        INTERFACE_LINK_LIBRARIES "\$<LINK_ONLY:\$<\$<NOT:${z_vcpkg_skia_config_debug}>:${z_vcpkg_skia_link_libs_release}>>"
    )

    if(NOT "@SKIA_LIB_DBG@" STREQUAL "")
        z_vcpkg_skia_get_link_libraries(
            z_vcpkg_skia_link_libs_debug
            "${z_vcpkg_skia_root}/debug/lib;${z_vcpkg_skia_root}/lib"
            "@SKIA_DEP_DBG@"
        )
        set_property(TARGET unofficial::skia::@name@ APPEND PROPERTY
            IMPORTED_CONFIGURATIONS DEBUG
        )
        set_target_properties(unofficial::skia::@name@ PROPERTIES
            IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
            IMPORTED_LOCATION_DEBUG "${z_vcpkg_skia_root}/debug/lib/@SKIA_LIB_DBG@"
        )
        set_property(TARGET unofficial::skia::@name@ APPEND PROPERTY
            INTERFACE_COMPILE_DEFINITIONS "\$<\$<CONFIG:Debug>:@SKIA_DEFINITIONS_DBG@>"
        )
        set_property(TARGET unofficial::skia::@name@ APPEND PROPERTY
            INTERFACE_LINK_LIBRARIES "\$<LINK_ONLY:\$<\$<CONFIG:Debug>:${z_vcpkg_skia_link_libs_debug}>>"
        )
    endif()
endif()
