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
        hip     STDGPU_BACKEND_HIP
)

# Ensure exactly one backend is selected
set(BACKEND_COUNT 0)
if(STDGPU_BACKEND_CUDA)
    math(EXPR BACKEND_COUNT "${BACKEND_COUNT} + 1")
    set(STDGPU_BACKEND "STDGPU_BACKEND_CUDA")
endif()
if(STDGPU_BACKEND_OPENMP)
    math(EXPR BACKEND_COUNT "${BACKEND_COUNT} + 1")
    set(STDGPU_BACKEND "STDGPU_BACKEND_OPENMP")
endif()
if(STDGPU_BACKEND_HIP)
    math(EXPR BACKEND_COUNT "${BACKEND_COUNT} + 1")
    set(STDGPU_BACKEND "STDGPU_BACKEND_HIP")
endif()

if(BACKEND_COUNT EQUAL 0)
    message(FATAL_ERROR "No backend selected. Please enable at least one backend feature: cuda, openmp, or hip")
elseif(BACKEND_COUNT GREATER 1)
    message(FATAL_ERROR "Multiple backends selected. Please enable only one backend feature: cuda, openmp, or hip")
endif()

# Check for thrust availability when using OpenMP backend (Linux only)
if(STDGPU_BACKEND_OPENMP)
    if(NOT EXISTS "/usr/include/thrust/version.h" AND NOT EXISTS "/usr/local/cuda/include/thrust/version.h")
        message(FATAL_ERROR "The OpenMP backend requires thrust headers. Please install thrust first:\n"
                            "  - On Ubuntu/Debian: sudo apt-get install libthrust-dev\n"
                            "  - Or install CUDA which includes thrust\n"
                            "  - On other systems, install thrust manually")
    endif()
endif()

# Check for HIP availability when using HIP backend
if(STDGPU_BACKEND_HIP)
    message(STATUS "HIP backend selected - requires ROCm/HIP SDK to be installed system-wide")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
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