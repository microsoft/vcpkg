if(TARGET firebird)
    return()
endif()

include(CMakeFindDependencyMacro)

set(_FIREBIRD_ROOT "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
set(_FIREBIRD_ROOT_DEBUG "${_FIREBIRD_ROOT}/debug")
set(_FIREBIRD_LIB_DIR "${_FIREBIRD_ROOT}/lib")
set(_FIREBIRD_LIB_DIR_DEBUG "${_FIREBIRD_ROOT_DEBUG}/lib")
set(_FIREBIRD_BIN_DIR "${_FIREBIRD_ROOT}/bin")
set(_FIREBIRD_BIN_DIR_DEBUG "${_FIREBIRD_ROOT_DEBUG}/bin")

set(_FIREBIRD_SELECTED_LINKAGE "")
set(_FIREBIRD_SHARED_FILENAME "")

if(WIN32)
    if(EXISTS "${_FIREBIRD_LIB_DIR}/fbclient_ms.lib")
        set(_FIREBIRD_SELECTED_LINKAGE "shared")
    elseif(EXISTS "${_FIREBIRD_LIB_DIR}/fbclient_static_ms.lib")
        set(_FIREBIRD_SELECTED_LINKAGE "static")
    endif()
else()
    foreach(_FIREBIRD_SHARED_CANDIDATE libfbclient.so libfbclient.dylib)
        if(EXISTS "${_FIREBIRD_LIB_DIR}/${_FIREBIRD_SHARED_CANDIDATE}")
            set(_FIREBIRD_SELECTED_LINKAGE "shared")
            set(_FIREBIRD_SHARED_FILENAME "${_FIREBIRD_SHARED_CANDIDATE}")
            break()
        endif()
    endforeach()
    if(NOT _FIREBIRD_SELECTED_LINKAGE AND EXISTS "${_FIREBIRD_LIB_DIR}/libfbclient_static.a")
        set(_FIREBIRD_SELECTED_LINKAGE "static")
    endif()
endif()

if(NOT _FIREBIRD_SELECTED_LINKAGE)
    message(FATAL_ERROR "Firebird client libraries were not found under ${_FIREBIRD_ROOT}.")
endif()

if(_FIREBIRD_SELECTED_LINKAGE STREQUAL "shared")
    add_library(firebird SHARED IMPORTED)
else()
    add_library(firebird STATIC IMPORTED)
endif()

if(_FIREBIRD_SELECTED_LINKAGE STREQUAL "static")
    find_dependency(libtommath CONFIG REQUIRED)
    set(_FIREBIRD_TOMMATH_TARGET "libtommath")
    if(TARGET libtommath::libtommath)
        set(_FIREBIRD_TOMMATH_TARGET "libtommath::libtommath")
    endif()
    # LINK_ONLY keeps CMake from validating libtommath's include directories here.
    set_property(TARGET firebird APPEND PROPERTY
        INTERFACE_LINK_LIBRARIES "$<LINK_ONLY:${_FIREBIRD_TOMMATH_TARGET}>"
    )
endif()

set_target_properties(firebird PROPERTIES
    IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/../../include/"
)

if(WIN32)
    if(_FIREBIRD_SELECTED_LINKAGE STREQUAL "shared")
        set(_FIREBIRD_IMPLIB_RELEASE "${_FIREBIRD_LIB_DIR}/fbclient_ms.lib")
        set(_FIREBIRD_IMPLIB_DEBUG "${_FIREBIRD_LIB_DIR_DEBUG}/fbclient_ms.lib")
        if(NOT EXISTS "${_FIREBIRD_IMPLIB_DEBUG}")
            set(_FIREBIRD_IMPLIB_DEBUG "${_FIREBIRD_IMPLIB_RELEASE}")
        endif()

        set(_FIREBIRD_DLL_RELEASE "${_FIREBIRD_BIN_DIR}/fbclient.dll")
        set(_FIREBIRD_DLL_DEBUG "${_FIREBIRD_BIN_DIR_DEBUG}/fbclient.dll")
        if(NOT EXISTS "${_FIREBIRD_DLL_DEBUG}")
            set(_FIREBIRD_DLL_DEBUG "${_FIREBIRD_DLL_RELEASE}")
        endif()

        set_target_properties(firebird PROPERTIES
            IMPORTED_IMPLIB_RELEASE "${_FIREBIRD_IMPLIB_RELEASE}"
            IMPORTED_IMPLIB_DEBUG "${_FIREBIRD_IMPLIB_DEBUG}"
            IMPORTED_LOCATION_RELEASE "${_FIREBIRD_DLL_RELEASE}"
            IMPORTED_LOCATION_DEBUG "${_FIREBIRD_DLL_DEBUG}"
        )
    else()
        set(_FIREBIRD_STATIC_RELEASE "${_FIREBIRD_LIB_DIR}/fbclient_static_ms.lib")
        set(_FIREBIRD_STATIC_DEBUG "${_FIREBIRD_LIB_DIR_DEBUG}/fbclient_static_ms.lib")
        if(NOT EXISTS "${_FIREBIRD_STATIC_DEBUG}")
            set(_FIREBIRD_STATIC_DEBUG "${_FIREBIRD_STATIC_RELEASE}")
        endif()

        set_target_properties(firebird PROPERTIES
            IMPORTED_LOCATION_RELEASE "${_FIREBIRD_STATIC_RELEASE}"
            IMPORTED_LOCATION_DEBUG "${_FIREBIRD_STATIC_DEBUG}"
        )
    endif()
else()
    if(_FIREBIRD_SELECTED_LINKAGE STREQUAL "shared")
        set(_FIREBIRD_SHARED_RELEASE "${_FIREBIRD_LIB_DIR}/${_FIREBIRD_SHARED_FILENAME}")
        set(_FIREBIRD_SHARED_DEBUG "${_FIREBIRD_LIB_DIR_DEBUG}/${_FIREBIRD_SHARED_FILENAME}")
        if(NOT EXISTS "${_FIREBIRD_SHARED_DEBUG}")
            set(_FIREBIRD_SHARED_DEBUG "${_FIREBIRD_SHARED_RELEASE}")
        endif()

        set_target_properties(firebird PROPERTIES
            IMPORTED_LOCATION_RELEASE "${_FIREBIRD_SHARED_RELEASE}"
            IMPORTED_LOCATION_DEBUG "${_FIREBIRD_SHARED_DEBUG}"
        )
    else()
        set(_FIREBIRD_STATIC_RELEASE "${_FIREBIRD_LIB_DIR}/libfbclient_static.a")
        set(_FIREBIRD_STATIC_DEBUG "${_FIREBIRD_LIB_DIR_DEBUG}/libfbclient_static.a")
        if(NOT EXISTS "${_FIREBIRD_STATIC_DEBUG}")
            set(_FIREBIRD_STATIC_DEBUG "${_FIREBIRD_STATIC_RELEASE}")
        endif()

        set_target_properties(firebird PROPERTIES
            IMPORTED_LOCATION_RELEASE "${_FIREBIRD_STATIC_RELEASE}"
            IMPORTED_LOCATION_DEBUG "${_FIREBIRD_STATIC_DEBUG}"
        )
    endif()
endif()

unset(_FIREBIRD_ROOT)
unset(_FIREBIRD_ROOT_DEBUG)
unset(_FIREBIRD_LIB_DIR)
unset(_FIREBIRD_LIB_DIR_DEBUG)
unset(_FIREBIRD_BIN_DIR)
unset(_FIREBIRD_BIN_DIR_DEBUG)
unset(_FIREBIRD_SELECTED_LINKAGE)
unset(_FIREBIRD_SHARED_FILENAME)
unset(_FIREBIRD_SHARED_CANDIDATE)
unset(_FIREBIRD_SHARED_RELEASE)
unset(_FIREBIRD_SHARED_DEBUG)
unset(_FIREBIRD_IMPLIB_RELEASE)
unset(_FIREBIRD_IMPLIB_DEBUG)
unset(_FIREBIRD_DLL_RELEASE)
unset(_FIREBIRD_DLL_DEBUG)
unset(_FIREBIRD_STATIC_RELEASE)
unset(_FIREBIRD_STATIC_DEBUG)
unset(_FIREBIRD_TOMMATH_TARGET)
