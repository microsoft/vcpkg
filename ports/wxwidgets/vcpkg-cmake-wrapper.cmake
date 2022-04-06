get_filename_component(wxWidgets_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(wxWidgets_ROOT_DIR "${wxWidgets_ROOT_DIR}" CACHE INTERNAL "" FORCE)
set(WX_ROOT_DIR "${wxWidgets_ROOT_DIR}")
set(wxWidgets_LIB_DIR "${wxWidgets_ROOT_DIR}/lib" CACHE INTERNAL "" FORCE)
set(WX_LIB_DIR "${wxWidgets_LIB_DIR}")
find_library(WX_based NAMES wxbase31ud PATHS "${wxWidgets_ROOT_DIR}/debug/lib" NO_DEFAULT_PATH)
file(GLOB WX_LIBS_DEBUG "${wxWidgets_ROOT_DIR}/debug/lib/wx*.lib")
foreach(WX_LIB_DEBUG ${WX_LIBS_DEBUG})
    string(REGEX REPLACE ".*wx([^/]*)d_([^/\\.]*)\\.[^/\\.]*\$" "WX_\\2d" varname "${WX_LIB_DEBUG}")
    set(${varname} "${WX_LIB_DEBUG}" CACHE INTERNAL "" FORCE)
endforeach()
_find_package(${ARGS})

find_package(ZLIB QUIET)
find_package(libpng CONFIG QUIET)
find_package(TIFF QUIET)
find_package(expat CONFIG QUIET)


set(external_LIBS "TIFF::TIFF;expat::expat;ZLIB::ZLIB")
if (TARGET png)
    list(APPEND external_LIBS "png")
elseif(TARGET png_static)
    list(APPEND external_LIBS "png_static")
endif()


set(_wxWidgets_LIBRARIES)
foreach(entry ${wxWidgets_LIBRARIES})

    get_filename_component(LIB_NAME_RELEASE ${entry} NAME)
    get_filename_component(LIB_NAME_WLE_RELEASE ${entry} NAME_WLE)

    if(IS_ABSOLUTE ${entry} AND ${LIB_NAME_WLE_RELEASE} MATCHES "^wx[a-z0-9]+u(|_.*)\$")
        if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
            add_library(${LIB_NAME_WLE_RELEASE} STATIC IMPORTED)
        else()
            add_library(${LIB_NAME_WLE_RELEASE} SHARED IMPORTED)
        endif()

        list(APPEND _wxWidgets_LIBRARIES ${LIB_NAME_WLE_RELEASE})

        string(REGEX REPLACE "(wx[a-z0-9]+u)([_.].*)\$" "\\1d\\2" LIB_NAME_DEBUG "${LIB_NAME_RELEASE}")
        get_filename_component(LIB_NAME_WLE_DEBUG ${LIB_NAME_DEBUG} NAME_WLE)

        if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
            set_target_properties(${LIB_NAME_WLE_RELEASE} PROPERTIES
                IMPORTED_LOCATION_RELEASE "${wxWidgets_ROOT_DIR}/lib/${LIB_NAME_RELEASE}"
                IMPORTED_LOCATION_DEBUG "${wxWidgets_ROOT_DIR}/debug/lib/${LIB_NAME_DEBUG}"
            )
        else()
            set_target_properties(${LIB_NAME_WLE_RELEASE} PROPERTIES
                IMPORTED_LOCATION_RELEASE "${wxWidgets_ROOT_DIR}/bin/${LIB_NAME_RELEASE}"
                IMPORTED_LOCATION_DEBUG "${wxWidgets_ROOT_DIR}/debug/bin/${LIB_NAME_DEBUG}"
            )
            if(MSVC)
                set_target_properties(${LIB_NAME_WLE_RELEASE} PROPERTIES
                    IMPORTED_IMPLIB_RELEASE "${wxWidgets_ROOT_DIR}/lib/${LIB_NAME_RELEASE}"
                    IMPORTED_IMPLIB_DEBUG "${wxWidgets_ROOT_DIR}/debug/lib/${LIB_NAME_DEBUG}"
                )
            endif()
        endif()

        set_target_properties(${LIB_NAME_WLE_RELEASE} PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${wxWidgets_ROOT_DIR}/include"
            IMPORTED_LINK_INTERFACE_LIBRARIES "${external_LIBS}"
        )
    else()
        list(APPEND _wxWidgets_LIBRARIES ${entry})
    endif()
endforeach()
set(wxWidgets_LIBRARIES ${_wxWidgets_LIBRARIES})
