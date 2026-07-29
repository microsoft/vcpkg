if(TARGET libbacktrace::libbacktrace)
    return()
endif()

find_path(LIBBACKTRACE_INCLUDE_DIR NAMES backtrace.h PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include" NO_DEFAULT_PATH)
find_library(LIBBACKTRACE_LIBRARY_RELEASE NAMES backtrace libbacktrace PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
find_library(LIBBACKTRACE_LIBRARY_DEBUG   NAMES backtrace libbacktrace PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)

include(SelectLibraryConfigurations)
select_library_configurations(LIBBACKTRACE)

if(NOT TARGET libbacktrace::libbacktrace)
    add_library(libbacktrace::libbacktrace UNKNOWN IMPORTED)
    set_target_properties(libbacktrace::libbacktrace PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${LIBBACKTRACE_INCLUDE_DIR}"
        IMPORTED_CONFIGURATIONS RELEASE
        IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
        IMPORTED_LOCATION_RELEASE "${LIBBACKTRACE_LIBRARY_RELEASE}"
    )
    if(LIBBACKTRACE_LIBRARY_DEBUG)
        set_property(TARGET libbacktrace::libbacktrace APPEND PROPERTY
            IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(libbacktrace::libbacktrace PROPERTIES
            IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
            IMPORTED_LOCATION_DEBUG "${LIBBACKTRACE_LIBRARY_DEBUG}")
    endif()
endif()
