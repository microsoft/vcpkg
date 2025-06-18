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
        cuda    STDGPU_BACKEND_CUDA
        openmp  STDGPU_BACKEND_OPENMP
)

# Backend selection: ensure exactly one backend is selected
set(BACKEND_COUNT 0)
if(STDGPU_BACKEND_CUDA)
    math(EXPR BACKEND_COUNT "${BACKEND_COUNT} + 1")
    set(STDGPU_BACKEND "STDGPU_BACKEND_CUDA")
endif()
if(STDGPU_BACKEND_OPENMP)
    math(EXPR BACKEND_COUNT "${BACKEND_COUNT} + 1")
    set(STDGPU_BACKEND "STDGPU_BACKEND_OPENMP")
endif()

if(BACKEND_COUNT EQUAL 0)
    # Default to OpenMP on Linux, error on other platforms
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        set(STDGPU_BACKEND "STDGPU_BACKEND_OPENMP")
        message(STATUS "No backend specified, defaulting to OpenMP backend")
    else()
        message(FATAL_ERROR "No backend selected. Please specify cuda or openmp feature.")
    endif()
elseif(BACKEND_COUNT GREATER 1)
    message(FATAL_ERROR "Multiple backends selected. Please enable only one backend feature: cuda or openmp")
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