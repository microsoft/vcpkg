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

# pkg-config in FindMPI.cmake works also in cross builds (when providing
# the pc files without the 'o' prefix, which is handled in port mpi.)
# Skip everything else.
set(MPI_ASSUME_NO_BUILTIN_MPI TRUE)
set(MPI_SKIP_COMPILER_WRAPPER TRUE)
set(MPI_SKIP_GUESSING TRUE)
find_program(PKG_CONFIG_EXECUTABLE NAMES pkgconf PATHS "${VCPKG_INSTALLED_DIR}/@HOST_TRIPLET@/tools/pkgconf" REQUIRED)
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

