vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO HEASARC/cfitsio
    REF "cfitsio-${VERSION}"
    SHA512 5db1b0c881169d2718cecff53c2de2ef2c93b933d48996025a0559ecff903f4aea0a0727aec0863b5eedafba4022325fcebd9092d50c427b3c1bab9a5c3fde6f
    HEAD_REF master
    PATCHES
        dependencies.diff
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bzip2       USE_BZIP2
        curl        USE_CURL
        pthreads    USE_PTHREADS
        tools       UTILS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTESTS=OFF
    OPTIONS_DEBUG
        -DUTILS=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cfitsio)

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES fitscopy fitsverify fpack funpack imcopy speed AUTO_CLEAN)
    if(EXISTS "${VCPKG_INSTALLED_DIR}/bin/smem${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        vcpkg_copy_tools(TOOL_NAMES smem AUTO_CLEAN)
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/licenses/License.txt")
