# This variable can be used for testing and for messages.
set(HDF5_WITH_PARALLEL [[
HDF5 was built with parallel support.
]])
if(PORT STREQUAL "seacas" AND NOT "mpi" IN_LIST FEATURES)
    message(WARNING "${HDF5_WITH_PARALLEL} Enabling MPI in seacas.")
    list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DTPL_ENABLE_MPI:BOOL=ON")
endif()
if(PORT STREQUAL "vtk" AND NOT "mpi" IN_LIST FEATURES)
    message(WARNING "${HDF5_WITH_PARALLEL} Enabling MPI in vtk.")
    list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DVTK_USE_MPI:BOOL=ON")
endif()
