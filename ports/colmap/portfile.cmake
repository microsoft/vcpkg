# Update both, literally.
set(COLMAP_REF 4.0.2 "d927f7e518fc20afa33390712c4cc20d85b730b8")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO colmap/colmap
    REF "${VERSION}"
    SHA512 b83956a5d60aa298b5c520f949a9fa6e15f715c3e5f34d3d9bd56fabfedd2cb19045bc799b09c33ae21abf2b81c9b3d2d0d0674580def4963a4966a8286cb0a1
    HEAD_REF main
    PATCHES
        no-glu.diff
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if (NOT TRIPLET_SYSTEM_ARCH STREQUAL "x64" AND ("cuda" IN_LIST FEATURES OR "cuda-redist" IN_LIST FEATURES))
    message(FATAL_ERROR "Feature cuda and cuda-redist require x64 triplet.")
endif()

# set GIT_COMMIT_ID and GIT_COMMIT_DATE
if(DEFINED VCPKG_HEAD_VERSION)
    set(GIT_COMMIT_ID "${VCPKG_HEAD_VERSION}")
elseif(NOT VERSION IN_LIST COLMAP_REF)
    message(FATAL_ERROR "Version ${VERSION} missing in COLMAP_REF (${COLMAP_REF})")
else()
    list(GET COLMAP_REF 1 GIT_COMMIT_ID)
endif()

string(TIMESTAMP COLMAP_GIT_COMMIT_DATE "%Y-%m-%d")

foreach(FEATURE ${FEATURE_OPTIONS})
    message(STATUS "${FEATURE}")
endforeach()

set(CUDA_ENABLED OFF)
set(GUI_ENABLED OFF)
set(CGAL_ENABLED OFF)
set(ONNX_ENABLED OFF)
set(OPENMP_ENABLED ON)

if("cuda" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "native")
endif()

if("cuda-redist" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "all-major")
endif()

if("gui" IN_LIST FEATURES)
    set(GUI_ENABLED ON)
endif()

if("cgal" IN_LIST FEATURES)
    set(CGAL_ENABLED ON)
endif()

if("onnx" IN_LIST FEATURES)
    set(ONNX_ENABLED ON)
endif()

if (VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    set(OPENMP_ENABLED OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DCUDA_ENABLED=${CUDA_ENABLED}
        -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}
        -DGUI_ENABLED=${GUI_ENABLED}
        -DGIT_COMMIT_ID=${GIT_COMMIT_ID}
        -DGIT_COMMIT_DATE=${COLMAP_GIT_COMMIT_DATE}
        -DOPENMP_ENABLED=${OPENMP_ENABLED}
        -DCGAL_ENABLED=${CGAL_ENABLED}
        -DTESTS_ENABLED=OFF
        -DFETCH_POSELIB=OFF
        -DFETCH_FAISS=OFF
        -DONNX_ENABLED=${ONNX_ENABLED}
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
)

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.txt")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
