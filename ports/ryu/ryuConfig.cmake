function(set_library_target NAMESPACE LIB_NAME DEBUG_LIB_FILE_NAME RELEASE_LIB_FILE_NAME INCLUDE_DIR)
    add_library(${NAMESPACE}::${LIB_NAME} STATIC IMPORTED)
    set_target_properties(${NAMESPACE}::${LIB_NAME} PROPERTIES
                          IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                          IMPORTED_LOCATION_RELEASE "${RELEASE_LIB_FILE_NAME}"
                          IMPORTED_LOCATION_DEBUG "${DEBUG_LIB_FILE_NAME}"
                          INTERFACE_INCLUDE_DIRECTORIES "${INCLUDE_DIR}"
                          )
    set(${NAMESPACE}_${LIB_NAME}_FOUND 1)
endfunction()

get_filename_component(ROOT "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(ROOT "${ROOT}" PATH)
get_filename_component(ROOT "${ROOT}" PATH)

if (TRUE)
find_library(RYU_RELEASE_LIB ryu PATHS "${ROOT}/lib" NO_DEFAULT_PATH)
find_library(RYU_DEBUG_LIB ryu PATHS "${ROOT}/debug/lib" NO_DEFAULT_PATH)
find_library(RYUPF_RELEASE_LIB ryu_printf PATHS "${ROOT}/lib" NO_DEFAULT_PATH)
find_library(RYUPF_DEBUG_LIB ryu_printf PATHS "${ROOT}/debug/lib" NO_DEFAULT_PATH)
set_library_target("RYU" "ryu" "${RYU_DEBUG_LIB}" "${RYU_RELEASE_LIB}" "${ROOT}/include/")
set_library_target("RYU" "ryu_printf" "${RYUPF_DEBUG_LIB}" "${RYUPF_RELEASE_LIB}" "${ROOT}/include/")
else()
set_library_target("RYU" "ryu" "${ROOT}/debug/lib/libryu.a" "${ROOT}/lib/libryu.a" "${ROOT}/include/")
set_library_target("RYU" "ryu_printf" "${ROOT}/debug/lib/libryu_printf.a" "${ROOT}/lib/libryu_printf.a" "${ROOT}/include/")
endif()
