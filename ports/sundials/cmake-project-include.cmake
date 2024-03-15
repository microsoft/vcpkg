if(ENABLE_GINKGO AND NOT TARGET Ginkgo::ginkgo)
    find_package(Ginkgo CONFIG REQUIRED)
    get_target_property(GINKGO_INCLUDE_DIR Ginkgo::ginkgo INTERFACE_INCLUDE_DIRECTORIES)
    set(GINKGO_LIBRARY_DIR "${CURRENT_INSTALLED_DIR}/lib")
endif()

if(ENABLE_HYPRE AND NOT TARGET SUNDIALS::HYPRE)
    find_package(MPI 2.0.0 REQUIRED)
    find_package(HYPRE CONFIG REQUIRED)
    get_target_property(HYPRE_INCLUDE_DIR HYPRE::HYPRE INTERFACE_INCLUDE_DIRECTORIES)
    list(REMOVE_DUPLICATES HYPRE_INCLUDE_DIR)
    set(HYPRE_LIBRARY_DIR "${CURRENT_INSTALLED_DIR}/lib")
    set(HYPRE_WORKS TRUE) # Skip MPI Test
    
    # Interface Target
    add_library(SUNDIALS::HYPRE INTERFACE IMPORTED)
    target_link_libraries(SUNDIALS::HYPRE INTERFACE HYPRE)
endif()

if(ENABLE_KLU AND NOT TARGET SUNDIALS::KLU)
    find_package(SuiteSparse CONFIG REQUIRED)
    set(KLU_LIBRARIES SuiteSparse::klu
                      SuiteSparse::amd
                      SuiteSparse::colamd
                      SuiteSparse::btf
                      SuiteSparse::suitesparseconfig)
    set(KLU_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include/suitesparse")
    set(KLU_LIBRARY_DIR "${CURRENT_INSTALLED_DIR}/lib")
    
    # Interface Target
    add_library(SUNDIALS::KLU INTERFACE IMPORTED)
    target_link_libraries(SUNDIALS::KLU INTERFACE "${KLU_LIBRARIES}")
endif()

if(ENABLE_MAGMA AND NOT TARGET SUNDIALS::MAGMA)
    find_package(LAPACK REQUIRED)
    find_package(CUDAToolkit REQUIRED)
    
    # Both pkg_find_module and FindMAGMA.cmake in SUNDIALS have issues
    # parsing magma.pc on Windows. Using find_library.
    set(MAGMA_FOUND FALSE)
    find_path(MAGMA_INCLUDE_DIR magma_v2.h)
    find_library(MAGMA_LIBRARIES magma)
    if(MAGMA_LIBRARIES)
        set(MAGMA_FOUND TRUE)
    endif()
    
    # Interface Target
    add_library(SUNDIALS::MAGMA INTERFACE IMPORTED)
    target_include_directories(SUNDIALS::MAGMA INTERFACE "${MAGMA_INCLUDE_DIR}")
    target_link_libraries(SUNDIALS::MAGMA INTERFACE
        "${MAGMA_LIBRARIES}"
        LAPACK::LAPACK
        CUDA::cudart
        CUDA::cublas
        CUDA::cusparse
    )
    
    # Override sundials/cmake/tpl/SundialsMAGMA.cmake
    set(MAGMA_WORKS TRUE)
    set(SUNDIALS_MAGMA_INCLUDED CACHE INTERNAL "vcpkg")
endif()
