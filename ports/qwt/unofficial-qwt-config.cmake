include(CMakeFindDependencyMacro)

if(NOT TARGET unofficial::qwt::qwt)
    find_dependency(Qt6 COMPONENTS Core Gui Widgets Svg OpenGL Concurrent PrintSupport OpenGLWidgets)

    find_file(qwt_LIBRARY_RELEASE_DLL NAMES qwt.dll PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin" NO_DEFAULT_PATH)
    find_file(qwt_LIBRARY_DEBUG_DLL NAMES qwtd.dll PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/bin" NO_DEFAULT_PATH)

    if(EXISTS "${qwt_LIBRARY_RELEASE_DLL}")
        add_library(unofficial::qwt::qwt SHARED IMPORTED)
        set_target_properties(unofficial::qwt::qwt PROPERTIES INTERFACE_COMPILE_DEFINITIONS QWT_DLL)
        set_property(TARGET unofficial::qwt::qwt APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        find_library(qwt_LIBRARY_RELEASE NAMES qwt PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH REQUIRED)
        set_target_properties(unofficial::qwt::qwt PROPERTIES IMPORTED_IMPLIB_RELEASE "${qwt_LIBRARY_RELEASE}")
        set_target_properties(unofficial::qwt::qwt PROPERTIES IMPORTED_LOCATION_RELEASE "${qwt_LIBRARY_RELEASE_DLL}")
        if(EXISTS "${qwt_LIBRARY_DEBUG_DLL}")
            set_property(TARGET unofficial::qwt::qwt APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
            find_library(qwt_LIBRARY_DEBUG NAMES qwtd PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH REQUIRED)
            set_target_properties(unofficial::qwt::qwt PROPERTIES IMPORTED_IMPLIB_DEBUG "${qwt_LIBRARY_DEBUG}")
            set_target_properties(unofficial::qwt::qwt PROPERTIES IMPORTED_LOCATION_DEBUG "${qwt_LIBRARY_DEBUG_DLL}")
        endif()
    else()
        add_library(unofficial::qwt::qwt UNKNOWN IMPORTED)
        find_library(qwt_LIBRARY_RELEASE NAMES qwt PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
        if(EXISTS "${qwt_LIBRARY_RELEASE}")
            set_property(TARGET unofficial::qwt::qwt APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
            set_target_properties(unofficial::qwt::qwt PROPERTIES IMPORTED_LOCATION_RELEASE "${qwt_LIBRARY_RELEASE}")
        endif()
        find_library(qwt_LIBRARY_DEBUG NAMES qwtd PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
        if(EXISTS "${qwt_LIBRARY_DEBUG}")
            set_property(TARGET unofficial::qwt::qwt APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
            set_target_properties(unofficial::qwt::qwt PROPERTIES IMPORTED_LOCATION_DEBUG "${qwt_LIBRARY_DEBUG}")
        endif()
    endif()

    set_target_properties(unofficial::qwt::qwt PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
    )
    target_link_libraries(unofficial::qwt::qwt
        INTERFACE
        Qt::Widgets
        Qt::Svg
        Qt::Concurrent
        Qt::PrintSupport
        Qt::OpenGL
        Qt::OpenGLWidgets
    )
endif()