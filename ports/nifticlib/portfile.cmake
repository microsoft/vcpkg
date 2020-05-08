vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO    NIFTI-Imaging/nifti_clib 
    REF 65f801b9c2f1f15f4de4a19d45e6595c25765632
    SHA512 be03cdc6cf17fd9ff74c5ecc1f6b2132121bb4b7973a731da334af2a8428d1f0dbbf7b94b2511d1ff7e515b8cc4cf3316d62b189566fb6ffc88c6146eebd48ff
    HEAD_REF master
    PATCHES zlib_include.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    "cifti"         USE_CIFTI_CODE
    "fsl"           USE_FSL_CODE
    "nifti2"        USE_NIFTI2_CODE
    "nifticdf"      USE_NIFTICDF_CODE
    "tools"         NIFTI_BUILD_APPLICATIONS
    "tests"         BUILD_TESTING
)
set(TOOL_NAMES)
if("tools" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES nifti_stats nifti_tool nifti1_tool)
endif()
if("tests" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES nifit_test) 
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake TARGET_PATH share)

if(TOOL_NAMES)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
