vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stotko/stdgpu
    REF 1.3.0
    SHA512 ea4999a28e3ee1eccb7ea3033b49ee783dfee9a577e3110ca210cf93f12242926182187e937cfa9b37465ea14e30880beca6a710446b13905d5d5872bdf31a19
    HEAD_REF master
)

# Copy our fixed Findthrust.cmake
file(COPY "${CMAKE_CURRENT_LIST_DIR}/Findthrust.cmake" DESTINATION "${SOURCE_PATH}/cmake/")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp  STDGPU_BACKEND_OPENMP
)

# Backend selection: try CUDA first, fallback to OpenMP if CUDA unavailable
find_program(CUDA_COMPILER nvcc)
if(STDGPU_BACKEND_OPENMP)
    set(STDGPU_BACKEND "STDGPU_BACKEND_OPENMP")
elseif(CUDA_COMPILER OR EXISTS "/usr/local/cuda/bin/nvcc")
    set(STDGPU_BACKEND "STDGPU_BACKEND_CUDA")
else()
    # CUDA compiler not found, fallback to OpenMP
    message(STATUS "CUDA compiler not found, falling back to OpenMP backend")
    set(STDGPU_BACKEND "STDGPU_BACKEND_OPENMP")
endif()

# Check for thrust availability when using OpenMP backend
if(STDGPU_BACKEND STREQUAL "STDGPU_BACKEND_OPENMP")
    # Try to find thrust from vcpkg CUDA package or system locations
    find_path(THRUST_INCLUDE_DIR 
        NAMES thrust/version.h
        PATHS
            "${CURRENT_INSTALLED_DIR}/include"
            "/usr/include"
            "/usr/local/cuda/include"
        NO_DEFAULT_PATH
    )
    
    if(NOT THRUST_INCLUDE_DIR)
        message(WARNING "Thrust headers not found for OpenMP backend. Continuing anyway as they might be found during build.")
    endif()
endif()

# Set CUDA architectures for CUDA backend to avoid GPU detection on CI
if(STDGPU_BACKEND STREQUAL "STDGPU_BACKEND_CUDA")
    # Use a minimal set of common architectures that work on CI
    set(CUDA_ARCH_OPTIONS -DCMAKE_CUDA_ARCHITECTURES=52)
else()
    set(CUDA_ARCH_OPTIONS "")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${CUDA_ARCH_OPTIONS}
        -DSTDGPU_BACKEND=${STDGPU_BACKEND}
        -DSTDGPU_BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DSTDGPU_BUILD_TESTS=OFF
        -DSTDGPU_BUILD_EXAMPLES=OFF
        -DSTDGPU_ENABLE_CONTRACT_CHECKS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/stdgpu)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")