# https://sandialabs.github.io/Zoltan/ug_html/ug_usage.html#Building%20the%20Library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  trilinos/Trilinos # probably easier to have a Trilinos port later and have all the subprojects as features of that port. 
    REF 2b1731bf967884b75a151dc1381686c0e86bcc81 # 2022-11-12
    SHA512 b0efcbc01ee8d25cdee6bed7faba7bc5aa294cfb82e3a83b34880755cb12be987bd7b9767631020e982adc58dc7126b42f2331064118751e031d78b8a6c4fb27
    HEAD_REF master
    PATCHES fix_deps.patch
            fix_tpl_libs.patch
            next.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
    list(APPEND FEATURE_OPTIONS "-DTPL_ENABLE_DLlib:BOOL=OFF"
                                "-DTrilinos_ENABLE_Zoltan:BOOL=OFF")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        mpi     TPL_ENABLE_MPI
)

# Pthread ? DLlib? RTlib?

set(tpl_disable_list MKL yaml-cpp Peano CUDA CUBLAS CUSOLVER CUSPARSE Thrust Cusp TBB 
                     HWLOC QTHREAD BinUtils ARPREC QD BOOST BLAS LAPACK Scotch OVIS gpcd 
                     DataWrap MTMETIS ParMETIS PuLP TopoManager LibTopoMap PaToH CppUnit
                     ADOLC ADIC TVMET MF ExodusII Nemesis XDMF Pnetcdf ADIOS2 Faodel Catalyst2
                     yl2m SuperLUDist SuperLUMT SuperLU Cholmod UMFPACK MA28 AMD CSparse
                     HYPRE PETSC BLACS SCALAPACK MUMPS STRUMPACK PARDISO_MKL PARDISO Oski
                     TAUCS ForUQTK Dakota HIPS MATLAB CASK SPARSKIT QT gtest BoostLib 
                     BoostAlbLib OpenNURBS Portals CrayPortals Gemini InfiniBand BGPDCMF
                     BGQPAMI Pablo HPCToolkit Clp GLPK gpOASES PAPI MATLABLib Eigen X11
                     Lemon GLM quadmath CAMAL AmgX CGAL CGALCore VTune TASMANIAN ArrayFireCPU
                     SimMesh SimModel SimParasolid SimAcis SimField Valgrind QUO
                     ViennaCL Avatar mlpack pebbl MAGMASparse Check SARMA)

set(tpl_enable_list CGNS HDF5 METIS Matio Netcdf Zlib fmt Cereal)

set(tpl_options "")
foreach(tpl IN LISTS tpl_disable_list)
    list(APPEND tpl_options "-DTPL_ENABLE_${tpl}:BOOL=OFF")
endforeach()
foreach(tpl IN LISTS tpl_enable_list)
    list(APPEND tpl_options "-DTPL_ENABLE_${tpl}:BOOL=ON")
endforeach()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        #--trace-expand
        -DBUILD_TESTING:BOOL=OFF
        -DTrilinos_ENABLE_ALL_PACKAGES:BOOL=OFF
        -DTrilinos_ENABLE_SEACAS:BOOL=ON
        -DTrilinos_ENABLE_Kokkos:BOOL=OFF
        -DTrilinos_USE_GNUINSTALLDIRS:BOOL=ON
        -DTrilinos_ENABLE_Fortran:BOOL=OFF
        -DTrilinos_ENABLE_TESTS:BOOL=OFF
        -DKokkos_ENABLE_TESTS:BOOL=OFF
        ${FEATURE_OPTIONS}
        ${tpl_options}
        "-DTrilinos_HOSTNAME:STRING=localhost"
        -DNetcdf_ALLOW_MODERN:BOOL=ON
    OPTIONS_DEBUG
        -DTrilinos_ENABLE_DEBUG:BOOL=OFF
    MAYBE_UNUSED_VARIABLES
        TPL_ENABLE_BOOST
        Trilinos_ENABLE_Seacas
)

vcpkg_cmake_install()

set(cmake_config_list tribits Trilinos SEACASExodus SEACASNemesis SEACASIoss SEACASChaco 
               SEACASAprepro SEACASAprepro_lib SEACASSuplibC SEACASSuplibCpp SEACASConjoin SEACASEjoin
               SEACASEpu SEACASExo2mat SEACASExomatlab  SEACASMat2exo SEACASExodiff SEACASExo_format SEACASNas2exo 
               SEACASCpup SEACASSlice SEACASZellij SEACASNemslice SEACASNemspread SEACAS)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND cmake_config_list Zoltan)
endif()

foreach(cmake_conig IN LISTS cmake_config_list)
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${cmake_conig}" PACKAGE_NAME cmake/${cmake_conig}DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION)
endforeach()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/external_packages" PACKAGE_NAME external_packages DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )

set(tool_names aprepro cgns_decomp conjoin cpup cth_pressure_map epu 
                       ejoin exo2mat exodiff exomatlab exo_format
                       io_info io_modify io_shell mat2exo nas2exo nem_slice nem_spread
                       shell_to_hex skinner slice sphgen struc_to_unstruc zellij)

if("mpi" IN_LIST FEATURES)
    list(APPEND tool_names pepu)
endif()


vcpkg_copy_tools(TOOL_NAMES ${tool_names} AUTO_CLEAN)

set(scripts decomp epup pconjoin)

foreach(script IN LISTS scripts)
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${script}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script}")
endforeach()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(GLOB remaining_bin_stuff "${CURRENT_PACKAGES_DIR}/bin/*" LIST_DIRECTORIES true)
    if(NOT remaining_bin_stuff)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    else()
        message(FATAL_ERROR "remaining_bin_stuff:${remaining_bin_stuff}")
    endif()
endif()

# vcpkg really needs: vcpkg_remove_dirs_if_empty(<dirs>)
file(GLOB remaining_cmake_dirs "${CURRENT_PACKAGES_DIR}/lib/cmake/*" LIST_DIRECTORIES true)
if(NOT remaining_cmake_dirs)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake" "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
else()
    message(FATAL_ERROR "remaining_cmake_dirs:${remaining_cmake_dirs}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")


file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
