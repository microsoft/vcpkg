if (WIN32)
    get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
    
    # Suitable for FindMPI.cmake line 937
    set(ENV{MSMPI_INC} "${_IMPORT_PREFIX}/include")
endif()

_find_package(${ARGS})

if (WIN32)
    unset(ENV{MSMPI_INC})
endif()
