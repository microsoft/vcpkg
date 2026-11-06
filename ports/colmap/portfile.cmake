if(EXISTS "${CURRENT_INSTALLED_DIR}/share/poselib/copyright")
    message(FATAL_ERROR "'${PORT}' conflicts with 'poselib'. Please remove poselib:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    # colmap does not export its symbols (no dllexport, no export header): it cannot be built as a DLL on Windows.
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

# Update all three, literally.
set(COLMAP_REF 4.2.1 "bd1fcf654d2dd8fefa1466999c190a246f83f4b9" "2026-09-29")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO colmap/colmap
    REF "${VERSION}"
    SHA512 53a49264eb1d43a8cd7fb5c734d7c2fe279d5d62875eb7f0f0a396ef8de2d02e72646c3e6d89c98affd2c044f7e26646e6cb67b0067b01773562fe6235c58fa3
    HEAD_REF main
    PATCHES
        no-glu.diff
        qt6-only.diff
        optional-opengl.diff
        cryptopp-config.diff
        caspar-msvc-force-include.diff
        caspar-public-headers.diff
)

# FETCHCONTENT_FULLY_DISCONNECTED is set by vcpkg: PoseLib must be downloaded here.
# Update both with colmap: src/thirdparty/CMakeLists.txt (FETCH_POSELIB).
vcpkg_from_github(
    OUT_SOURCE_PATH POSELIB_SOURCE_PATH
    REPO PoseLib/PoseLib
    REF fa7280fee27f97aff31ae7f98bab7f583fac7d08
    SHA512 624c8789bf99113ef23b987736eabc9b7844afdb2fd4d39e0bae086bcb59375f29e011d1bec82c8aff53df5515f4e84d6ec79ec0714e0c04db45992db56050e8
    HEAD_REF master
)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" AND ("cuda" IN_LIST FEATURES OR "cuda-redist" IN_LIST FEATURES))
    message(FATAL_ERROR "Features cuda and cuda-redist require an x64 triplet.")
endif()

if(DEFINED VCPKG_HEAD_VERSION)
    set(GIT_COMMIT_ID "${VCPKG_HEAD_VERSION}")
    string(TIMESTAMP GIT_COMMIT_DATE "%Y-%m-%d")
elseif(NOT VERSION IN_LIST COLMAP_REF)
    message(FATAL_ERROR "Version ${VERSION} missing in COLMAP_REF (${COLMAP_REF})")
else()
    list(GET COLMAP_REF 1 GIT_COMMIT_ID)
    list(GET COLMAP_REF 2 GIT_COMMIT_DATE)
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gui      GUI_ENABLED
        cgal     CGAL_ENABLED
        onnx     ONNX_ENABLED
        download DOWNLOAD_ENABLED
        caspar   CASPAR_ENABLED
)

set(CUDA_ENABLED OFF)
set(OPENMP_ENABLED ON)

if("cuda" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "native")
endif()

if("cuda-redist" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "all-major")
endif()

# With CUDA, colmap selects the CUDA execution provider of onnxruntime.
if(ONNX_ENABLED AND CUDA_ENABLED AND NOT "onnx-cuda" IN_LIST FEATURES)
    message(WARNING "Features cuda/cuda-redist and onnx without onnx-cuda: onnxruntime has no CUDA execution provider, run the ONNX-based tools with use_gpu=false.")
endif()

if (VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    set(OPENMP_ENABLED OFF)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    string(APPEND VCPKG_C_FLAGS " /bigobj")
    string(APPEND VCPKG_CXX_FLAGS " /bigobj")
endif()

if(CUDA_ENABLED)
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    if(CASPAR_ENABLED AND "cuda-redist" IN_LIST FEATURES)
        vcpkg_execute_required_process(
            COMMAND "${NVCC}" --list-gpu-code
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
            LOGNAME cuda-architectures
            OUTPUT_VARIABLE cuda_gpu_codes
        )
        string(REPLACE "\r" "" cuda_gpu_codes "${cuda_gpu_codes}")
        string(REPLACE "\n" ";" cuda_gpu_codes "${cuda_gpu_codes}")
        list(REMOVE_DUPLICATES cuda_gpu_codes)
        list(SORT cuda_gpu_codes COMPARE NATURAL)
        set(CUDA_ARCHITECTURES "")
        set(cuda_architecture_majors "")
        foreach(cuda_gpu_code IN LISTS cuda_gpu_codes)
            if(NOT cuda_gpu_code MATCHES "^sm_([0-9]+)$")
                continue()
            endif()
            set(cuda_architecture "${CMAKE_MATCH_1}")
            math(EXPR cuda_architecture_major "${cuda_architecture} / 10")
            if(cuda_architecture GREATER_EQUAL 75 AND NOT cuda_architecture_major IN_LIST cuda_architecture_majors)
                list(APPEND CUDA_ARCHITECTURES "${cuda_architecture}-real")
                list(APPEND cuda_architecture_majors "${cuda_architecture_major}")
                set(cuda_ptx_architecture "${cuda_architecture}")
            endif()
        endforeach()
        if(NOT CUDA_ARCHITECTURES)
            message(FATAL_ERROR "Caspar requires a CUDA toolkit supporting SM75 or newer.")
        endif()
        # Retain all-major redistribution coverage above Caspar's SM75 minimum.
        list(APPEND CUDA_ARCHITECTURES "${cuda_ptx_architecture}-virtual")
    endif()
    list(APPEND CUDA_OPTIONS
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
        "-DCUDAToolkit_ROOT=${cuda_toolkit_root}"
    )
endif()

if(CUDA_ENABLED AND VCPKG_TARGET_IS_WINDOWS)
    # CCCL >= 3.2 requires the conforming MSVC preprocessor
    list(APPEND CUDA_OPTIONS "-DCMAKE_CUDA_FLAGS_INIT=-Xcompiler=/Zc:preprocessor")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${CUDA_OPTIONS}
        ${FEATURE_OPTIONS}
        -DCMAKE_POLICY_DEFAULT_CMP0091=NEW
        -DCUDA_ENABLED=${CUDA_ENABLED}
        -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}
        -DGIT_COMMIT_ID=${GIT_COMMIT_ID}
        -DGIT_COMMIT_DATE=${GIT_COMMIT_DATE}
        -DOPENMP_ENABLED=${OPENMP_ENABLED}
        -DLSD_ENABLED=ON
        -DCOLMAP_HASH_MAP_BACKEND=STD
        -DCCACHE_ENABLED=OFF
        -DUNINSTALL_ENABLED=OFF
        -DTESTS_ENABLED=OFF
        -DFETCH_POSELIB=ON
        -DFETCHCONTENT_SOURCE_DIR_POSELIB=${POSELIB_SOURCE_PATH}
        -DFETCH_FAISS=OFF
        -DFETCH_ONNX=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(GLOB TOOL_FILENAMES "${CURRENT_PACKAGES_DIR}/bin/*")
foreach(TOOL_FILENAME ${TOOL_FILENAMES})
    get_filename_component(TEST_TOOL_NAME ${TOOL_FILENAME} NAME_WLE)
    list(APPEND COLMAP_TOOL_NAMES "${TEST_TOOL_NAME}")
endforeach()

vcpkg_copy_tools(TOOL_NAMES ${COLMAP_TOOL_NAMES} AUTO_CLEAN)

if(ONNX_ENABLED AND VCPKG_TARGET_IS_WINDOWS)
    # onnxruntime loads its providers with LoadLibrary: they are not detected by the dependency scan of vcpkg_copy_tools.
    file(GLOB ONNX_PROVIDER_DLLS "${CURRENT_INSTALLED_DIR}/bin/onnxruntime_providers_*.dll")
    if(ONNX_PROVIDER_DLLS)
        file(COPY ${ONNX_PROVIDER_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    endif()
endif()

if(GUI_ENABLED AND VCPKG_TARGET_IS_WINDOWS)
    # The tools are moved to tools/colmap: Qt must find its plugins (platforms/qwindows.dll) in the installed tree.
    file(WRITE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf" "[Paths]\nPrefix = ../..\nPlugins = Qt6/plugins\n")
endif()

# remove empty folders and unused files
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/include/colmap/exe"
    "${CURRENT_PACKAGES_DIR}/include/colmap/tools"
    "${CURRENT_PACKAGES_DIR}/include/colmap/ui/media"
    "${CURRENT_PACKAGES_DIR}/include/colmap/ui/shaders"
    "${CURRENT_PACKAGES_DIR}/COLMAP.bat"
    "${CURRENT_PACKAGES_DIR}/RUN_TESTS.bat"
    "${CURRENT_PACKAGES_DIR}/debug/COLMAP.bat"
    "${CURRENT_PACKAGES_DIR}/debug/RUN_TESTS.bat"
    "${CURRENT_PACKAGES_DIR}/debug/bin"
    "${CURRENT_PACKAGES_DIR}/share/colmap/cmake/vcpkg"
)

# Headers of the vendored PoseLib, required by the installed headers of colmap.
file(INSTALL "${POSELIB_SOURCE_PATH}/PoseLib" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/_deps/poselib-build/generated_headers/PoseLib" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")

vcpkg_copy_pdbs()

set(COPYRIGHT_FILES
    "${SOURCE_PATH}/COPYING.txt"
    "${POSELIB_SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/src/thirdparty/LSD/LICENSE"
    "${SOURCE_PATH}/src/thirdparty/LSD/lsd.h"
)
if(CASPAR_ENABLED)
    list(APPEND COPYRIGHT_FILES "${SOURCE_PATH}/src/thirdparty/Symforce-Caspar/LICENSE")
endif()
vcpkg_install_copyright(FILE_LIST ${COPYRIGHT_FILES})

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
