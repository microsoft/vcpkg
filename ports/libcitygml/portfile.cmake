vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jklimke/libcitygml
    REF 4dacf5d61da59fa7efd91ea6c3c0cf9a48c85bb4 # 2.4.3
    SHA512 765f9d05fba9108cb6f23803824a61ab0bf30b05ae4cf5c8faa87915c03bb3ad5c1fdc03d420aea2dd3708d60040d6e10232a714595ab161f6e1527f3176d2aa
    HEAD_REF master
    PATCHES
        0002_fix_tools.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        osg         LIBCITYGML_OSGPLUGIN
        gdal        LIBCITYGML_USE_GDAL
        tools       LIBCITYGML_TESTS
)

if ("osg" IN_LIST FEATURES)
    SET(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CITYGML_BUILD_DYNAMIC)
list(APPEND ADDITIONAL_OPTIONS -DLIBCITYGML_DYNAMIC=${CITYGML_BUILD_DYNAMIC})

if (VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_WINDOWS)
    string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" CITYGML_CRT_STATIC)
    list(APPEND ADDITIONAL_OPTIONS -DLIBCITYGML_STATIC_CRT=${CITYGML_CRT_STATIC})
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${ADDITIONAL_OPTIONS}
)

vcpkg_cmake_install()
if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_cmake_config_fixup(PACKAGE_NAME citygml CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME citygml CONFIG_PATH lib/cmake/citygml)
endif()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES citygmltest
        AUTO_CLEAN
    )
    if ("osg" IN_LIST FEATURES)
        vcpkg_copy_tools(
            TOOL_NAMES citygmlOsgViewer
            AUTO_CLEAN
        )
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

