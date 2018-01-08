find_package(HDF5 NO_MODULE REQUIRED)

set(HDF5_INCLUDE_DIRS ${HDF5_INCLUDE_DIR})

if(NOT TARGET vtk::hdf5::hdf5)
    add_library(vtk::hdf5::hdf5 INTERFACE IMPORTED GLOBAL)
    if(TARGET hdf5::hdf5-static)
        set_target_properties(vtk::hdf5::hdf5 PROPERTIES INTERFACE_LINK_LIBRARIES "hdf5::hdf5-static")
    elseif(TARGET hdf5::hdf5-shared)
        set_target_properties(vtk::hdf5::hdf5 PROPERTIES INTERFACE_LINK_LIBRARIES "hdf5::hdf5-shared")
    else()
        message(FATAL_ERROR "could not find target hdf5-*")
    endif()
endif()

if(NOT TARGET vtk::hdf5::hdf5_hl)
    add_library(vtk::hdf5::hdf5_hl INTERFACE IMPORTED GLOBAL)
    if(TARGET hdf5::hdf5_hl-static)
        set_target_properties(vtk::hdf5::hdf5_hl PROPERTIES INTERFACE_LINK_LIBRARIES "hdf5::hdf5_hl-static")
    elseif(TARGET hdf5::hdf5_hl-shared)
        set_target_properties(vtk::hdf5::hdf5_hl PROPERTIES INTERFACE_LINK_LIBRARIES "hdf5::hdf5_hl-shared")
    else()
        message(FATAL_ERROR "could not find target hdf5_hl-*")
    endif()
endif()

set(HDF5_LIBRARIES "$<BUILD_INTERFACE:vtk::hdf5::hdf5>" "$<BUILD_INTERFACE:vtk::hdf5::hdf5_hl>")

find_package_handle_standard_args(HDF5
    REQUIRED_VARS HDF5_INCLUDE_DIRS HDF5_LIBRARIES
)
