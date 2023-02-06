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

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES
    "cifti"         USE_CIFTI_CODE
    "fsl"           USE_FSL_CODE
    "nifti2"        USE_NIFTI2_CODE
    "nifticdf"      USE_NIFTICDF_CODE
    "tools"         NIFTI_BUILD_APPLICATIONS
    "tests"         BUILD_TESTING
)
set(TOOL_NAMES)
if("tools" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES nifti1_tool) 
    if("nifti2" IN_LIST FEATURES)
        list(APPEND TOOL_NAMES nifti_tool) 
    endif()
    if("nifticdf" IN_LIST FEATURES)
        list(APPEND TOOL_NAMES nifti_stats) 
    endif()
    if("cifti" IN_LIST FEATURES AND "nifti2" IN_LIST FEATURES)
        list(APPEND TOOL_NAMES cifti_tool afni_xml_tool) 
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake)

if(TOOL_NAMES)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
