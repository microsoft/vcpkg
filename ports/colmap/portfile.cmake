set(COLMAP_REF "3.6-dev.3")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO colmap/colmap
    REF ${COLMAP_REF}
    SHA512 7eec27fced20f43547e67e9824d33c8412b17c2c80d29d8346d583cef3f7598b59c7c10a0556b857e31106c9312aace54c5dee65b8465974930f35b58331304a
    HEAD_REF dev
)

set(CUDA_ENABLED OFF)
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    cuda CUDA_ENABLED
)

if(DEFINED VCPKG_HEAD_VERSION)
    set(COLMAP_GIT_COMMIT_ID "${VCPKG_HEAD_VERSION}")
else()
    set(COLMAP_GIT_COMMIT_ID "${COLMAP_REF}")
endif()

string(TIMESTAMP COLMAP_GIT_COMMIT_DATE "%Y-%m-%d")

if("cuda-redist" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHS "Common")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCUDA_ENABLED=${CUDA_ENABLED}
        -DCUDA_ARCHS=${CUDA_ARCHS}
        -DGIT_COMMIT_ID=${COLMAP_GIT_COMMIT_ID}
        -DGIT_COMMIT_DATE=${COLMAP_GIT_COMMIT_DATE}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

vcpkg_copy_tools(TOOL_NAMES colmap AUTO_CLEAN)

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
