function(set_library_target NAMESPACE LIB_NAME DEBUG_DIR RELEASE_DIR INCLUDE_DIR)
    add_library(${NAMESPACE}::${LIB_NAME} STATIC IMPORTED)
    
    find_library (RELEASE_LIB_FILE_NAME NAMES "lib${LIB_NAME}.a" PATHS ${RELEASE_DIR} NO_DEFAULT_PATH)
    if (RELEASE_LIB_FILE_NAME)
        set(LIBODBC_USE_STATIC_LIB true)
    endif()
    find_library (RELEASE_LIB_FILE_NAME NAMES ${LIB_NAME} PATHS ${RELEASE_DIR} NO_DEFAULT_PATH)
    find_library (DEBUG_LIB_FILE_NAME NAMES "lib${LIB_NAME}.a" PATHS ${DEBUG_DIR} NO_DEFAULT_PATH)
    if (DEBUG_LIB_FILE_NAME)
        set(LIBODBC_USE_STATIC_LIB true)
    endif()
    find_library (DEBUG_LIB_FILE_NAME NAMES ${LIB_NAME} PATHS ${DEBUG_DIR} NO_DEFAULT_PATH)
    set_target_properties(${NAMESPACE}::${LIB_NAME} PROPERTIES
                          IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                          IMPORTED_LOCATION_RELEASE "${RELEASE_LIB_FILE_NAME}"
                          IMPORTED_LOCATION_DEBUG "${DEBUG_LIB_FILE_NAME}"
                          INTERFACE_INCLUDE_DIRECTORIES "${INCLUDE_DIR}"
                          )
    if(LIBODBC_USE_STATIC_LIB)
        find_package(Iconv MODULE)
        set_property(TARGET ${NAMESPACE}::${LIB_NAME} PROPERTY INTERFACE_LINK_LIBRARIES ${CMAKE_DL_LIBS} Iconv::Iconv)
    endif()
    set(${NAMESPACE}_${LIB_NAME}_FOUND 1)
endfunction()

get_filename_component(ROOT "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(ROOT "${ROOT}" PATH)
get_filename_component(ROOT "${ROOT}" PATH)

set_library_target("UNIX" "odbc" "${ROOT}/debug/lib/" "${ROOT}/lib/" "${ROOT}/include/")