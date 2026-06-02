if(NOT DEFINED MPI_HOME)
    set(MPI_HOME "${VCPKG_INSTALLED_DIR}/@TARGET_TRIPLET@" CACHE INTERNAL "vcpkg")
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

# Seed FindMPI from vcpkg's OpenMPI layout. The pkg-config path remains
# available for metadata probing, including cross builds.
set(MPI_ASSUME_NO_BUILTIN_MPI TRUE)
set(MPI_SKIP_COMPILER_WRAPPER TRUE)
set(MPI_SKIP_GUESSING TRUE)

if(NOT MPI_C_INCLUDE_PATH)
    set(MPI_C_INCLUDE_PATH "${MPI_HOME}/include" CACHE PATH "vcpkg" FORCE)
endif()
if(NOT MPI_CXX_INCLUDE_PATH)
    set(MPI_CXX_INCLUDE_PATH "${MPI_HOME}/include" CACHE PATH "vcpkg" FORCE)
endif()
if(NOT MPI_C_LIB_NAMES)
    set(MPI_C_LIB_NAMES mpi CACHE STRING "vcpkg" FORCE)
endif()
if(NOT MPI_CXX_LIB_NAMES)
    set(MPI_CXX_LIB_NAMES mpi CACHE STRING "vcpkg" FORCE)
endif()
set(MPI_CXX_SKIP_MPICXX ON CACHE BOOL "vcpkg")

if(NOT DEFINED CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE MATCHES "^[Dd][Ee][Bb][Uu][Gg]$")
    set(z_vcpkg_mpi_library_dir "${MPI_HOME}/debug/lib")
else()
    set(z_vcpkg_mpi_library_dir "${MPI_HOME}/lib")
endif()
if(NOT MPI_mpi_LIBRARY)
    find_library(MPI_mpi_LIBRARY NAMES mpi PATHS "${z_vcpkg_mpi_library_dir}" NO_DEFAULT_PATH)
endif()
unset(z_vcpkg_mpi_library_dir)

find_program(PKG_CONFIG_EXECUTABLE NAMES pkg-config pkgconf PATHS "${VCPKG_INSTALLED_DIR}/@HOST_TRIPLET@/tools/bin" NO_DEFAULT_PATH)
find_package(PkgConfig)
set(z_vcpkg_mpiexec_pkg_config_path "$ENV{PKG_CONFIG_PATH}")
if(NOT DEFINED CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE MATCHES "^[Dd][Ee][Bb][Uu][Gg]$")
    set(ENV{PKG_CONFIG_PATH} "${VCPKG_INSTALLED_DIR}/@TARGET_TRIPLET@/debug/lib/pkgconfig")
else()
    set(ENV{PKG_CONFIG_PATH} "${VCPKG_INSTALLED_DIR}/@TARGET_TRIPLET@/lib/pkgconfig")
endif()
if(z_vcpkg_mpiexec_pkg_config_path)
    string(APPEND ENV{PKG_CONFIG_PATH} ":${z_vcpkg_mpiexec_pkg_config_path}")
endif()

_find_package(${ARGS})

set(ENV{PKG_CONFIG_PATH} "${z_vcpkg_mpiexec_pkg_config_path}")
unset(z_vcpkg_mpiexec_pkg_config_path)
