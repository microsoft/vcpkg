# Update all three, literally.
set(COLMAP_REF 4.1.1 "a0d785fba74b2664f31edc4a29026a8b27c00f67" "2026-07-17")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO colmap/colmap
    REF "${VERSION}"
    SHA512 0e0da65dfe422872ce0802e062226b38f36e6276f293156f7c16fe106eef785bab5816fb63b4c0a61ccd5b0a5848b19f7efbe8283bd0fa6acd941c70e4e643d1
    HEAD_REF main
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

set(CUDA_ENABLED OFF)

if("cuda" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "native")
elseif("cuda-redist" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "all-major")
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cgal      CGAL_ENABLED
        download  DOWNLOAD_ENABLED
        gui       GUI_ENABLED
        onnx      ONNX_ENABLED
)

set(OPENMP_ENABLED ON)
if(VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    set(OPENMP_ENABLED OFF)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    string(APPEND VCPKG_C_FLAGS " /bigobj")
    string(APPEND VCPKG_CXX_FLAGS " /bigobj")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}
        -DCUDA_ENABLED=${CUDA_ENABLED}
        -DFETCH_FAISS=OFF
        -DFETCH_ONNX=OFF
        -DFETCH_POSELIB=OFF
        -DGIT_COMMIT_DATE=${GIT_COMMIT_DATE}
        -DGIT_COMMIT_ID=${GIT_COMMIT_ID}
        -DOPENMP_ENABLED=${OPENMP_ENABLED}
        -DTESTS_ENABLED=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(GLOB TOOL_FILENAMES "${CURRENT_PACKAGES_DIR}/bin/*")
foreach(TOOL_FILENAME IN LISTS TOOL_FILENAMES)
    get_filename_component(TEST_TOOL_NAME "${TOOL_FILENAME}" NAME_WLE)
    list(APPEND COLMAP_TOOL_NAMES "${TEST_TOOL_NAME}")
endforeach()
vcpkg_copy_tools(TOOL_NAMES ${COLMAP_TOOL_NAMES} AUTO_CLEAN)

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
)

vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
