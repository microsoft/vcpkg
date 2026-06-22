vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  sandialabs/seacas
    REF v${VERSION}
    SHA512 f4278ec2d187fc1bcf9c3c7c3d45f4bff9ce36bbd793ffb8c745ae9706435bcf0bfc35233f5d1f4380ba1d7f49d41bd843a863e98a0bd9121c7a56158d0da8d8
    HEAD_REF master
    PATCHES 
        deps-and-shared.patch
        fix-mpi.patch
)

if(HDF5_WITH_PARALLEL AND NOT "mpi" IN_LIST FEATURES)
    message(WARNING "${HDF5_WITH_PARALLEL} Enabling MPI in seacas.")
    list(APPEND FEATURES "mpi")
elseif(NOT VCPKG_TARGET_IS_OSX)
    set(PARMETIS_FEATURES mpi TPL_ENABLE_ParMETIS)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        mpi     TPL_ENABLE_MPI
        matio   TPL_ENABLE_Matio
        # mpi     TPL_ENABLE_Pnetcdf # missing Pnetcdf port
        ${PARMETIS_FEATURES}
)

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND FEATURE_OPTIONS "-DTPL_ENABLE_DLlib:BOOL=OFF")
endif()

set(tpl_disable_list GTest DataWarp Pamgen X11 CUDA Kokkos Faodel Pnetcdf ADIOS2 Catalyst2)

set(tpl_enable_list Zlib HDF5 Netcdf CGNS fmt Cereal)

if(VCPKG_TARGET_IS_OSX)
    list(APPEND tpl_disable_list METIS)
else()
    list(APPEND tpl_enable_list METIS)
endif()

set(tpl_options "")
foreach(tpl IN LISTS tpl_disable_list)
    list(APPEND tpl_options "-DTPL_ENABLE_${tpl}:BOOL=OFF")
endforeach()
foreach(tpl IN LISTS tpl_enable_list)
    list(APPEND tpl_options "-DTPL_ENABLE_${tpl}:BOOL=ON")
endforeach()

set(disabled_projects Chaco Aprepro_lib SuplibC SuplibCpp Nemslice Nemspread Nas2exo Cpup Epu Ejoin Conjoin Aprepro Exo_format)
set(proj_options "")
foreach(proj IN LISTS disabled_projects)
    list(APPEND proj_options "-DSeacas_ENABLE_SEACAS${proj}:BOOL=OFF")
endforeach()
set(enabled_projects Ioss Nemesis Exodus)
set(proj_options "")
foreach(proj IN LISTS disabled_projects)
    list(APPEND proj_options "-DSeacas_ENABLE_SEACAS${proj}:BOOL=OFF")
endforeach()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DCGNS_FORCE_MODERN=ON
        -DNetcdf_ALLOW_MODERN=ON
        -DNetcdf_FORCE_MODERN=ON
        -DSeacas_ENABLE_Fortran:BOOL=OFF
        -DSeacas_ENABLE_SEACAS:BOOL=ON
        -DSeacas_ENABLE_Zoltan:BOOL=OFF
        -DSeacas_HOSTNAME:STRING=localhost
        -DSeacas_GENERATE_REPO_VERSION_FILE:BOOL=OFF
        ${proj_options}
        ${tpl_options}
)

vcpkg_cmake_install()

set(cmake_config_list ${enabled_projects})
list(TRANSFORM cmake_config_list PREPEND "SEACAS")
list(APPEND cmake_config_list SEACAS)

foreach(cmake_conig IN LISTS cmake_config_list)
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${cmake_conig}" PACKAGE_NAME cmake/${cmake_conig} DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION)
endforeach()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/external_packages" PACKAGE_NAME external_packages DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/Seacas")
    # Case sensitive filesystems will have two Seacas folders
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Seacas" PACKAGE_NAME cmake/Seacas DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION)
endif()

set(tool_names  cgns_decomp cth_pressure_map
                io_info io_modify io_shell
                shell_to_hex skinner sphgen struc_to_unstruc)

vcpkg_copy_tools(TOOL_NAMES ${tool_names} AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(GLOB remaining_bin_stuff "${CURRENT_PACKAGES_DIR}/bin/*" LIST_DIRECTORIES true)
    if(NOT remaining_bin_stuff)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    else()
        message(WARNING "remaining_bin_stuff:${remaining_bin_stuff}")
    endif()
endif()

# vcpkg really needs: vcpkg_remove_dirs_if_empty(<dirs>)
file(GLOB remaining_cmake_dirs "${CURRENT_PACKAGES_DIR}/lib/cmake/*" LIST_DIRECTORIES true)
if(NOT remaining_cmake_dirs)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake" "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
else()
    message(WARNING "remaining_cmake_dirs:${remaining_cmake_dirs}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
#file(REMOVE "${CURRENT_PACKAGES_DIR}/include/SeacasConfig.cmake")

file(GLOB_RECURSE python_files LIST_DIRECTORIES true "${CURRENT_PACKAGES_DIR}/lib/*.py" "${CURRENT_PACKAGES_DIR}/debug/lib/*.py")
if(python_files)
    file(REMOVE ${python_files})
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
