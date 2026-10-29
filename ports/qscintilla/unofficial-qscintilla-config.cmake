if(NOT TARGET unofficial::qscintilla::qscintilla)
    include(CMakeFindDependencyMacro)
    find_dependency(Qt6Widgets CONFIG)
    if(NOT IOS)
        find_dependency(Qt6PrintSupport CONFIG)
    endif()

    add_library(unofficial::qscintilla::qscintilla UNKNOWN IMPORTED)
    get_filename_component(z_vcpkg_qscintilla_root "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(z_vcpkg_qscintilla_root "${z_vcpkg_qscintilla_root}" PATH)
    get_filename_component(z_vcpkg_qscintilla_root "${z_vcpkg_qscintilla_root}" PATH)
    
    set_target_properties(unofficial::qscintilla::qscintilla PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${z_vcpkg_qscintilla_root}/include"
      INTERFACE_LINK_LIBRARIES Qt6::Widgets
    )

    if(NOT IOS)
        set_property(TARGET unofficial::qscintilla::qscintilla APPEND PROPERTY INTERFACE_LINK_LIBRARIES Qt6::PrintSupport)
    endif()
    
    find_library(Z_VCPKG_QSCINTILLA_LIBRARY_RELEASE NAMES libqscintilla2_qt6 qscintilla2_qt6 PATHS "${z_vcpkg_qscintilla_root}/lib" NO_DEFAULT_PATH)
    if(EXISTS "${Z_VCPKG_QSCINTILLA_LIBRARY_RELEASE}")
        set_property(TARGET unofficial::qscintilla::qscintilla APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        set_target_properties(unofficial::qscintilla::qscintilla PROPERTIES
            IMPORTED_LOCATION_RELEASE "${Z_VCPKG_QSCINTILLA_LIBRARY_RELEASE}")
    endif()

    find_library(Z_VCPKG_QSCINTILLA_LIBRARY_DEBUG NAMES libqscintilla2_qt6 qscintilla2_qt6d libqscintilla2_qt6_debug PATHS "${z_vcpkg_qscintilla_root}/debug/lib" NO_DEFAULT_PATH)
    if(EXISTS "${Z_VCPKG_QSCINTILLA_LIBRARY_DEBUG}")
        set_property(TARGET unofficial::qscintilla::qscintilla APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(unofficial::qscintilla::qscintilla PROPERTIES
            IMPORTED_LOCATION_DEBUG "${Z_VCPKG_QSCINTILLA_LIBRARY_DEBUG}")
    endif()

    unset(z_vcpkg_qscintilla_root)
endif()
