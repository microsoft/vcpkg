include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

get_filename_component(_NWAU_C_ABI_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)

find_path(NWAU_C_ABI_INCLUDE_DIR
    NAMES nwau_abi.h
    PATHS "${_NWAU_C_ABI_PREFIX}/include"
    NO_DEFAULT_PATH
)

find_library(NWAU_C_ABI_LIBRARY_RELEASE
    NAMES nwau_c_abi libnwau_c_abi
    PATHS "${_NWAU_C_ABI_PREFIX}/lib"
    NO_DEFAULT_PATH
)

find_library(NWAU_C_ABI_LIBRARY_DEBUG
    NAMES nwau_c_abi libnwau_c_abi
    PATHS "${_NWAU_C_ABI_PREFIX}/debug/lib"
    NO_DEFAULT_PATH
)

select_library_configurations(NWAU_C_ABI)

find_package_handle_standard_args(nwau-c-abi
    REQUIRED_VARS NWAU_C_ABI_INCLUDE_DIR NWAU_C_ABI_LIBRARY
)

if(nwau-c-abi_FOUND AND NOT TARGET nwau-c-abi::nwau-c-abi)
    add_library(nwau-c-abi::nwau-c-abi UNKNOWN IMPORTED)
    set_target_properties(nwau-c-abi::nwau-c-abi PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${NWAU_C_ABI_INCLUDE_DIR}"
    )
    if(NWAU_C_ABI_LIBRARY_RELEASE)
        set_property(TARGET nwau-c-abi::nwau-c-abi APPEND PROPERTY
            IMPORTED_CONFIGURATIONS RELEASE
        )
        set_target_properties(nwau-c-abi::nwau-c-abi PROPERTIES
            IMPORTED_LOCATION_RELEASE "${NWAU_C_ABI_LIBRARY_RELEASE}"
        )
    endif()
    if(NWAU_C_ABI_LIBRARY_DEBUG)
        set_property(TARGET nwau-c-abi::nwau-c-abi APPEND PROPERTY
            IMPORTED_CONFIGURATIONS DEBUG
        )
        set_target_properties(nwau-c-abi::nwau-c-abi PROPERTIES
            IMPORTED_LOCATION_DEBUG "${NWAU_C_ABI_LIBRARY_DEBUG}"
        )
    endif()
endif()
