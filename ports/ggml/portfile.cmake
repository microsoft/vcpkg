vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ggml-org/ggml
    REF 44ea6eda2ad8a94663597cbe85e37de98bd99269
    SHA512 be93d44f87ef25f7c0bb37ca8020de7714ec89b4f92677d7b631a2dcad9db38789e59adb7a6af0d1f5f550c570d875ea9ed69833f7d7af76ef8cb9159f0a7c23
    HEAD_REF master
    PATCHES
        android-vulkan.diff
        cmake-config.diff
        fix-32bit.diff
        relax-link-options.diff
        vulkan-shaders-gen.diff
        blas.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        blas     GGML_BLAS
        cuda     GGML_CUDA
        metal    GGML_METAL
        opencl   GGML_OPENCL
        openmp   GGML_OPENMP
        vulkan   GGML_VULKAN
)

if("blas" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PKGCONFIG)
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_REQUIRE_FIND_PACKAGE_BLAS=ON" # workaround message(ERROR ...)
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
    )
endif()

if("cuda" IN_LIST FEATURES)
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
        "-DCUDAToolkit_ROOT=${cuda_toolkit_root}"
    )
endif()

if("opencl" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND FEATURE_OPTIONS
        "-DPython3_EXECUTABLE=${PYTHON3}"
    )
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    message(STATUS "The CPU backend is not supported for arm64 with MSVC.")
    list(APPEND FEATURE_OPTIONS
        "-DGGML_CPU=OFF"
    )
    if(FEATURES STREQUAL "core")
        message(WARNING "No backend enabled!")
    endif()
endif()

if("vulkan" IN_LIST FEATURES AND VCPKG_CROSSCOMPILING)
    list(APPEND FEATURE_OPTIONS
        "-DVulkan_GLSLC_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/shaderc/glslc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        "-DVULKAN_SHADERS_GEN_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/vulkan-shaders-gen${VCPKG_HOST_EXECUTABLE_SUFFIX}"
    )
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static"  GGML_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGGML_STATIC=${GGML_STATIC}
        -DGGML_CCACHE=OFF
        -DGGML_BUILD_NUMBER=1
        -DGGML_BUILD_TESTS=OFF
        -DGGML_BUILD_EXAMPLES=OFF
        -DGGML_HIP=OFF
        -DGGML_SYCL=OFF
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        PKG_CONFIG_EXECUTABLE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ggml CONFIG_PATH "lib/cmake/ggml")
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ggml.h" "#ifdef GGML_SHARED" "#if 1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ggml-backend.h" "#ifdef GGML_BACKEND_SHARED" "#if 1")
endif()

if (NOT VCPKG_BUILD_TYPE)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/ggml.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/ggml.pc")
endif()
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/ggml.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/ggml.pc")
vcpkg_fixup_pkgconfig()

if("vulkan" IN_LIST FEATURES AND NOT VCPKG_CROSSCOMPILING)
    vcpkg_copy_tools(TOOL_NAMES vulkan-shaders-gen AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/pkgconfig")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
