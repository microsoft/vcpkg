# Custom MPI finder for MUMPS that includes all required MPI libraries
# This module creates a MUMPS_MPI::MUMPS_MPI target with all the MPI libraries
# that MUMPS needs, including the Fortran interface libraries.

include(FindPackageHandleStandardArgs)

# First find the standard MPI
find_package(MPI REQUIRED COMPONENTS C)

# Get the MPI library directory from the standard MPI target
get_target_property(MPI_C_LIBRARIES MPI::MPI_C INTERFACE_LINK_LIBRARIES)

# Extract the library directory from one of the MPI libraries
if(MPI_C_LIBRARIES)
    foreach(lib IN LISTS MPI_C_LIBRARIES)
        if(EXISTS "${lib}" AND NOT IS_DIRECTORY "${lib}")
            get_filename_component(MPI_LIB_DIR "${lib}" DIRECTORY)
            break()
        endif()
    endforeach()
endif()

# Define the list of MPI libraries that MUMPS needs based on platform
if(WIN32)
    # Windows with MS-MPI
    set(MUMPS_MPI_LIBRARY_NAMES
        msmpi
    )
else()
    # Linux/Unix with OpenMPI or similar
    set(MUMPS_MPI_LIBRARY_NAMES
        #mpi_usempif08
        #mpi_usempi_ignore_tkr
        #mpi_mpifh
        mpi
    )
endif()

# Find each required MPI library
set(MUMPS_MPI_LIBRARIES "")
set(MUMPS_MPI_LIBRARIES_FOUND TRUE)

foreach(lib_name IN LISTS MUMPS_MPI_LIBRARY_NAMES)
    find_library(MUMPS_MPI_${lib_name}_LIBRARY
        NAMES ${lib_name}
        HINTS ${MPI_LIB_DIR}
        DOC "Location of lib${lib_name} for MUMPS MPI support"
    )
    
    if(MUMPS_MPI_${lib_name}_LIBRARY)
        list(APPEND MUMPS_MPI_LIBRARIES ${MUMPS_MPI_${lib_name}_LIBRARY})
        message(STATUS "Found ${MUMPS_MPI_${lib_name}_LIBRARY}")
        mark_as_advanced(MUMPS_MPI_${lib_name}_LIBRARY)
    else()
        set(MUMPS_MPI_LIBRARIES_FOUND FALSE)
        message(STATUS "Could not find MPI library: ${lib_name}")
    endif()
endforeach()

# Create the MUMPS_MPI target
if(MUMPS_MPI_LIBRARIES_FOUND AND NOT TARGET MUMPS_MPI::MUMPS_MPI)
    add_library(MUMPS_MPI::MUMPS_MPI INTERFACE IMPORTED)
    
    # Link all the MUMPS-specific MPI libraries
    set_target_properties(MUMPS_MPI::MUMPS_MPI PROPERTIES
        INTERFACE_LINK_LIBRARIES "${MUMPS_MPI_LIBRARIES}"
    )
    
    # Also inherit properties from the standard MPI targets
    get_target_property(MPI_C_INCLUDE_DIRS MPI::MPI_C INTERFACE_INCLUDE_DIRECTORIES)
    get_target_property(MPI_C_COMPILE_OPTIONS MPI::MPI_C INTERFACE_COMPILE_OPTIONS)
    get_target_property(MPI_C_COMPILE_DEFINITIONS MPI::MPI_C INTERFACE_COMPILE_DEFINITIONS)
    
    if(MPI_C_INCLUDE_DIRS)
        set_target_properties(MUMPS_MPI::MUMPS_MPI PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${MPI_C_INCLUDE_DIRS}"
        )
    endif()
    
    if(MPI_C_COMPILE_OPTIONS)
        set_target_properties(MUMPS_MPI::MUMPS_MPI PROPERTIES
            INTERFACE_COMPILE_OPTIONS "${MPI_C_COMPILE_OPTIONS}"
        )
    endif()
    
    if(MPI_C_COMPILE_DEFINITIONS)
        set_target_properties(MUMPS_MPI::MUMPS_MPI PROPERTIES
            INTERFACE_COMPILE_DEFINITIONS "${MPI_C_COMPILE_DEFINITIONS}"
        )
    endif()
endif()

# Handle the find_package result
find_package_handle_standard_args(MUMPS_MPI
    REQUIRED_VARS MUMPS_MPI_LIBRARIES_FOUND
    FAIL_MESSAGE "Could not find all required MPI libraries for MUMPS"
)

# Set the found variable
set(MUMPS_MPI_FOUND ${MUMPS_MPI_LIBRARIES_FOUND})
