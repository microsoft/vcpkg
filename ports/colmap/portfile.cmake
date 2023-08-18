set(COLMAP_REF "323fc385c112001c670907adfa3815861674fc09") # Aug 18, 2023

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO colmap/colmap
    REF "${COLMAP_REF}"
    SHA512 d1b374303a8084303f5374bac81649e80e5309a7e0c9c42d2ddf32bb04ddc73842461938db88f511a993cd7e6906ec82d1feec580ae9cf9c5460c0aad9c97acd
    HEAD_REF main
)

if (NOT TRIPLET_SYSTEM_ARCH STREQUAL "x64" AND ("cuda" IN_LIST FEATURES OR "cuda-redist" IN_LIST FEATURES))
    message(FATAL_ERROR "Feature cuda and cuda-redist require x64 triplet.")
endif()

# set GIT_COMMIT_ID and GIT_COMMIT_DATE
if(DEFINED VCPKG_HEAD_VERSION)
    set(GIT_COMMIT_ID "${VCPKG_HEAD_VERSION}")
else()
    set(GIT_COMMIT_ID "${COLMAP_REF}")
endif()

string(TIMESTAMP COLMAP_GIT_COMMIT_DATE "%Y-%m-%d")

set(CUDA_ENABLED OFF)
set(TESTS_ENABLED OFF)

if("cuda" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "native")
endif()

if("cuda-redist" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "all-major")
endif()

if("tests" IN_LIST FEATURES)
    set(TESTS_ENABLED ON)
endif()

set(OPENMP_ENABLED ON)
if (VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    set(OPENMP_ENABLED Off)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DCUDA_ENABLED=${CUDA_ENABLED}
        -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}
        -DTESTS_ENABLED=${TESTS_ENABLED}
        -DGIT_COMMIT_ID=${GIT_COMMIT_ID}
        -DGIT_COMMIT_DATE=${COLMAP_GIT_COMMIT_DATE}
        -DOPENMP_ENABLED=${OPENMP_ENABLED}
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
    "${CURRENT_PACKAGES_DIR}/include/colmap/lib/Graclus/multilevelLib"
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

file(INSTALL "${SOURCE_PATH}/COPYING.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
