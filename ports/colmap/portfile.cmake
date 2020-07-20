set(COLMAP_REF "3.6-dev.3")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO colmap/colmap
    REF ${COLMAP_REF}
    SHA512 7eec27fced20f43547e67e9824d33c8412b17c2c80d29d8346d583cef3f7598b59c7c10a0556b857e31106c9312aace54c5dee65b8465974930f35b58331304a
    HEAD_REF dev
)

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
endif()

if("cuda-redist" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHS "Common")
endif()

if("tests" IN_LIST FEATURES)
    set(TESTS_ENABLED ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCUDA_ENABLED=${CUDA_ENABLED}
        -DCUDA_ARCHS=${CUDA_ARCHS}
        -DTESTS_ENABLED=${TESTS_ENABLED}
        -DGIT_COMMIT_ID=${GIT_COMMIT_ID}
        -DGIT_COMMIT_DATE=${COLMAP_GIT_COMMIT_DATE}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

file(GLOB TOOL_FILENAMES "${CURRENT_PACKAGES_DIR}/bin/*")
foreach(TOOL_FILENAME ${TOOL_FILENAMES})
    get_filename_component(TEST_TOOL_NAME ${TOOL_FILENAME} NAME_WLE)
    list(APPEND COLMAP_TOOL_NAMES "${TEST_TOOL_NAME}")
endforeach()

vcpkg_copy_tools(TOOL_NAMES ${COLMAP_TOOL_NAMES} AUTO_CLEAN)

# remove empty folders and unused files
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/debug/include/colmap/exe
    ${CURRENT_PACKAGES_DIR}/debug/include/colmap/lib/Graclus/multilevelLib
    ${CURRENT_PACKAGES_DIR}/debug/include/colmap/tools
    ${CURRENT_PACKAGES_DIR}/debug/include/colmap/ui/media
    ${CURRENT_PACKAGES_DIR}/debug/include/colmap/ui/shaders
    ${CURRENT_PACKAGES_DIR}/include/colmap/exe
    ${CURRENT_PACKAGES_DIR}/include/colmap/lib/Graclus/multilevelLib
    ${CURRENT_PACKAGES_DIR}/include/colmap/tools
    ${CURRENT_PACKAGES_DIR}/include/colmap/ui/media
    ${CURRENT_PACKAGES_DIR}/include/colmap/ui/shaders
    ${CURRENT_PACKAGES_DIR}/COLMAP.bat
    ${CURRENT_PACKAGES_DIR}/RUN_TESTS.bat
    ${CURRENT_PACKAGES_DIR}/debug/COLMAP.bat
    ${CURRENT_PACKAGES_DIR}/debug/RUN_TESTS.bat
    ${CURRENT_PACKAGES_DIR}/debug/bin
)

vcpkg_copy_pdbs()

file(INSTALL     ${SOURCE_PATH}/COPYING.txt
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
     RENAME copyright
)
