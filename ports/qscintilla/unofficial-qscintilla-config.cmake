if(NOT TARGET unofficial::qscintilla::qscintilla)
    add_library(unofficial::qscintilla::qscintilla UNKNOWN IMPORTED)
    get_filename_component(z_vcpkg_qscintilla_root "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(z_vcpkg_qscintilla_root "${z_vcpkg_qscintilla_root}" PATH)
    get_filename_component(z_vcpkg_qscintilla_root "${z_vcpkg_qscintilla_root}" PATH)

    include(CMakeFindDependencyMacro)
    find_dependency(Qt6PrintSupport CONFIG)
    find_dependency(Qt6Widgets CONFIG)

    set_target_properties(unofficial::qscintilla::qscintilla PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${z_vcpkg_qscintilla_root}/include"
    )

    find_library(Z_VCPKG_QSCINTILLA_LIBRARY_RELEASE NAMES libqscintilla2_qt6 qscintilla2_qt6 PATHS "${z_vcpkg_qscintilla_root}/lib" NO_DEFAULT_PATH)
    if(EXISTS "${Z_VCPKG_QSCINTILLA_LIBRARY_RELEASE}")
        set_property(TARGET unofficial::qscintilla::qscintilla APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        set_target_properties(unofficial::qscintilla::qscintilla PROPERTIES
            IMPORTED_LOCATION_RELEASE "${Z_VCPKG_QSCINTILLA_LIBRARY_RELEASE}"
            INTERFACE_LINK_LIBRARIES "Qt::PrintSupport;Qt6::PrintSupport;Qt::PrintSupportPrivate;Qt6::PrintSupportPrivate;Qt::Widgets;Qt6::Widgets;Qt::WidgetsPrivate;Qt6::WidgetsPrivate")
    endif()

    find_library(Z_VCPKG_QSCINTILLA_LIBRARY_DEBUG NAMES libqscintilla2_qt6 qscintilla2_qt6d libqscintilla2_qt6_debug PATHS "${z_vcpkg_qscintilla_root}/debug/lib" NO_DEFAULT_PATH)
    if(EXISTS "${Z_VCPKG_QSCINTILLA_LIBRARY_DEBUG}")
        set_property(TARGET unofficial::qscintilla::qscintilla APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(unofficial::qscintilla::qscintilla PROPERTIES
            IMPORTED_LOCATION_DEBUG "${Z_VCPKG_QSCINTILLA_LIBRARY_DEBUG}"
            INTERFACE_LINK_LIBRARIES "Qt::PrintSupport;Qt6::PrintSupport;Qt::PrintSupportPrivate;Qt6::PrintSupportPrivate;Qt::Widgets;Qt6::Widgets;Qt::WidgetsPrivate;Qt6::WidgetsPrivate")
    endif()

    unset(z_vcpkg_qscintilla_root)
endif()
