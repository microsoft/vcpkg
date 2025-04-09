if(NOT DEFINED MPI_HOME)
    set(MPI_HOME "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" CACHE INTERNAL "vcpkg")
    set(z_vcpkg_mpiexec_directories
        "${MPI_HOME}/tools/openmpi/bin"
        "${MPI_HOME}/tools/openmpi/debug/bin"
    )
    if(NOT DEFINED CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE MATCHES "^[Dd][Ee][Bb][Uu][Gg]$")
        list(REVERSE z_vcpkg_mpiexec_directories)
    endif()
    find_program(MPIEXEC_EXECUTABLE NAMES mpiexec PATHS ${z_vcpkg_mpiexec_directories} NO_DEFAULT_PATH)
    unset(z_vcpkg_mpiexec_directories)
endif()
_find_package(${ARGS})
