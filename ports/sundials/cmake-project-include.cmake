if(ENABLE_LAPACK)
    # Override sundials/cmake/tpl/SundialsLapack.cmake
    find_package(LAPACK REQUIRED)
    set(SUNDIALS_LAPACK_INCLUDED CACHE INTERNAL "vcpkg")
endif()

if(ENABLE_GINKGO AND NOT TARGET Ginkgo::ginkgo)
    # Override sundials/cmake/tpl/SundialsGinkgo.cmake
    find_package(Ginkgo CONFIG REQUIRED)
    set(SUNDIALS_GINKGO_INCLUDED CACHE INTERNAL "vcpkg")
endif()

if(ENABLE_HYPRE AND NOT TARGET SUNDIALS::HYPRE)
    # Override sundials/cmake/tpl/SundialsHypre.cmake
    find_package(HYPRE CONFIG REQUIRED)
    get_target_property(HYPRE_LIBRARIES HYPRE::HYPRE INTERFACE_LINK_LIBRARIES)
    get_target_property(HYPRE_INCLUDE_DIR HYPRE::HYPRE INTERFACE_INCLUDE_DIRECTORIES)
    list(REMOVE_DUPLICATES HYPRE_INCLUDE_DIR)
    set(SUNDIALS_HYPRE_INCLUDED CACHE INTERNAL "vcpkg")
    
    # Interface Target
    add_library(SUNDIALS::HYPRE INTERFACE IMPORTED)
    target_link_libraries(SUNDIALS::HYPRE INTERFACE HYPRE)
endif()

if(ENABLE_KLU AND NOT TARGET SUNDIALS::KLU)
    # Override sundials/cmake/tpl/SundialsKLU.cmake
    find_package(SuiteSparse CONFIG REQUIRED)
    set(KLU_LIBRARIES SuiteSparse::klu
                      SuiteSparse::amd
                      SuiteSparse::colamd
                      SuiteSparse::btf
                      SuiteSparse::suitesparseconfig)
    set(KLU_INCLUDE_DIR "${SuiteSparse_INCLUDE_DIRS}")
    set(SUNDIALS_KLU_INCLUDED CACHE INTERNAL "vcpkg")
    
    # Interface Target
    add_library(SUNDIALS::KLU INTERFACE IMPORTED)
    target_link_libraries(SUNDIALS::KLU INTERFACE "${KLU_LIBRARIES}")
endif()

if(ENABLE_MAGMA AND NOT TARGET SUNDIALS::MAGMA)
    # Override sundials/cmake/tpl/SundialsMAGMA.cmake
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(PC_MAGMA REQUIRED IMPORTED_TARGET magma)
    set(MAGMA_LIBRARIES "${PC_MAGMA_LIBRARIES}")
    set(MAGMA_INCLUDE_DIR "${PC_MAGMA_INCLUDEDIR}")
    set(SUNDIALS_MAGMA_INCLUDED CACHE INTERNAL "vcpkg")
    
    # Interface Target
    add_library(SUNDIALS::MAGMA INTERFACE IMPORTED)
    target_link_libraries(SUNDIALS::MAGMA INTERFACE PkgConfig::PC_MAGMA)
endif()
