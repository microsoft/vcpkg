vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  NIFTI-Imaging/nifti_clib 
    REF 5a8016be2161058f116b39ca476734bd81bb83c5
    SHA512 782cb4e494d73b054f8e3ab5f059b952fa461ceb3a0e12989ef1485675d1009d107c496abe6a495fbc30214d92859faad2c58a3edb10899114b440476b613315
    HEAD_REF master
    PATCHES
        zlib_include.patch
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
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/NIFTI PACKAGE_NAME nifti)

if(TOOL_NAMES)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
