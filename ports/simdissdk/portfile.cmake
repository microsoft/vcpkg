vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO USNavalResearchLaboratory/simdissdk
    HEAD_REF main
    REF "34fad5a"
    SHA512 494df2ee327036f5858fcc8a0bdc23c70951bd33a77e2e3a7691fce19e261a415d2cdeff7ca270d991a028ce5b864290d80ffd23a659dc64fd61c570bc1c8158
    PATCHES
        add-using-vcpkg-option.patch
        change-install-dir.patch
        change-osgqt-to-osgQOpenGL.patch
        disable-add-executable.patch
        disable-plugin-webp.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        simdata     BUILD_SIMDATA
        simvis      BUILD_SIMVIS
        simutil     BUILD_SIMUTIL
        simqt       BUILD_SIMQT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DINSTALL_THIRDPARTY_LIBRARIES=OFF
        -DBUILD_SDK_EXAMPLES=OFF
    OPTIONS_DEBUG
    MAYBE_UNUSED_VARIABLES
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME simCore 
    CONFIG_PATH lib/cmake/simCore 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
if(BUILD_SIMDATA)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simData 
    CONFIG_PATH lib/cmake/simData 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simDataProto 
    CONFIG_PATH lib/cmake/simDataProto 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
endif()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simNotify 
    CONFIG_PATH lib/cmake/simNotify 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
if(BUILD_SIMQT)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simQt 
    CONFIG_PATH lib/cmake/simQt 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
endif()
if(BUILD_SIMUTIL)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simUtil 
    CONFIG_PATH lib/cmake/simUtil 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
endif()
if(BUILD_SIMVIS)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simVis 
    CONFIG_PATH lib/cmake/simVis 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
endif()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME simdissdk 
    CONFIG_PATH lib/cmake
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(SIMNOTIFY_SHARED OFF)
    set(SIMCORE_SHARED OFF)
    set(SIMDATA_SHARED OFF)
    set(SIMDATAPROTO_SHARED OFF)
    set(SIMVIS_SHARED OFF)
    set(SIMUTIL_SHARED OFF)
    set(SIMQT_SHARED OFF)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/doc")
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/ExternalSdkProject")

#set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)
#set(VCPKG_POLICY_SKIP_MISPLACED_CMAKE_FILES_CHECK enabled)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${SOURCE_PATH}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/INSTALL.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/LICENSE.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/README.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/INSTALL.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/LICENSE.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/README.md")
