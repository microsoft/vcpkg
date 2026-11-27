get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_DIR}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

if(NOT TARGET unofficial::webview2::webview2)
    if(EXISTS "${_IMPORT_PREFIX}/lib/WebView2LoaderStatic.lib")
        add_library(unofficial::webview2::webview2 STATIC IMPORTED)
        set_target_properties(unofficial::webview2::webview2
            PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
                IMPORTED_LOCATION "${_IMPORT_PREFIX}/lib/WebView2LoaderStatic.lib")
    else()
        add_library(unofficial::webview2::webview2 SHARED IMPORTED)
        set_target_properties(unofficial::webview2::webview2
            PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
                IMPORTED_LOCATION "${_IMPORT_PREFIX}/bin/WebView2Loader.dll"
                IMPORTED_IMPLIB "${_IMPORT_PREFIX}/lib/WebView2Loader.dll.lib")
    endif()
endif()

unset(_IMPORT_PREFIX)
