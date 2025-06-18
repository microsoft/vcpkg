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

# Backend selection: CUDA (default) or OpenMP
if(STDGPU_BACKEND_OPENMP)
    set(STDGPU_BACKEND "STDGPU_BACKEND_OPENMP")
else()
    set(STDGPU_BACKEND "STDGPU_BACKEND_CUDA")
endif()

# Check for thrust availability when using OpenMP backend (Linux only)
if(STDGPU_BACKEND STREQUAL "STDGPU_BACKEND_OPENMP")
    if(NOT EXISTS "/usr/include/thrust/version.h" AND NOT EXISTS "/usr/local/cuda/include/thrust/version.h")
        message(FATAL_ERROR "The OpenMP backend requires thrust headers. Please install thrust first:\n"
                            "  - On Ubuntu/Debian: sudo apt-get install libthrust-dev\n"
                            "  - Or install CUDA which includes thrust\n"
                            "  - On other systems, install thrust manually")
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