
function(set_library_target)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "NAMESPACE;LIB_NAME;DEBUG_STATIC;RELEASE_STATIC;DEBUG_DYNAMIC;RELEASE_DYNAMIC;INCLUDE_DIR;TYPE" "")
    
    if (arg_DEBUG_DYNAMIC)
        set(ISAL_PROPERTIES IMPORTED_LOCATION_DEBUG "${arg_DEBUG_DYNAMIC}" IMPORTED_IMPLIB_DEBUG "${arg_DEBUG_STATIC}")
    else()
        set(ISAL_PROPERTIES IMPORTED_LOCATION_DEBUG "${arg_DEBUG_STATIC}")
    endif()
    
    if (arg_RELEASE_DYNAMIC)
        set(ISAL_PROPERTIES IMPORTED_LOCATION_RELEASE "${arg_RELEASE_DYNAMIC}" IMPORTED_IMPLIB_DEBUG "${arg_RELEASE_STATIC}")
    else()
        set(ISAL_PROPERTIES IMPORTED_LOCATION_RELEASE "${arg_RELEASE_STATIC}")
    endif()
    
    add_library(${arg_NAMESPACE}::${arg_LIB_NAME} ${arg_TYPE} IMPORTED)
    set_target_properties(${arg_NAMESPACE}::${arg_LIB_NAME} PROPERTIES
                          IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                          ${ISAL_PROPERTIES}
                          INTERFACE_INCLUDE_DIRECTORIES "${arg_INCLUDE_DIR}"
    )

    set(${NAMESPACE}_${LIB_NAME}_FOUND 1)
endfunction()

get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

if (WIN32)
    if ("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
        set_library_target(
            NAMESPACE "ISAL"
            LIB_NAME "isa-l"
            DEBUG_STATIC "${_IMPORT_PREFIX}/debug/lib/isa-l_static.lib"
            RELEASE_STATIC "${_IMPORT_PREFIX}/lib/isa-l_static.lib"
            INCLUDE_DIR "${_IMPORT_PREFIX}/include/isal"
            TYPE STATIC
        )
    else()
        set_library_target(
            NAMESPACE "ISAL"
            LIB_NAME "isal"
            DEBUG_DYNAMIC "${_IMPORT_PREFIX}/debug/bin/isa-l.dll"
            RELEASE_DYNAMIC "${_IMPORT_PREFIX}/bin/isa-l.dll"
            DEBUG_STATIC "${_IMPORT_PREFIX}/debug/lib/isa-l.lib"
            RELEASE_STATIC "${_IMPORT_PREFIX}/lib/isa-l.lib"
            INCLUDE_DIR "${_IMPORT_PREFIX}/include/isal"
            TYPE SHARED
        )
    endif()
else()
    if ("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
        set_library_target(
            NAMESPACE "ISAL"
            LIB_NAME "isa-l"
            DEBUG_STATIC "${_IMPORT_PREFIX}/debug/lib/libisal.a"
            RELEASE_STATIC "${_IMPORT_PREFIX}/lib/libisal.a"
            INCLUDE_DIR "${_IMPORT_PREFIX}/include"
            TYPE STATIC
        )
    else()
        set_library_target(
            NAMESPACE "ISAL"
            LIB_NAME "isal"
            DEBUG_DYNAMIC "${_IMPORT_PREFIX}/debug/lib/libisal.so"
            RELEASE_DYNAMIC "${_IMPORT_PREFIX}/lib/libisal.so"
            INCLUDE_DIR "${_IMPORT_PREFIX}/include"
            TYPE SHARED
        )
    endif()
endif()
